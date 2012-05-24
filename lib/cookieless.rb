require 'digest/sha1'
require 'uri'

module Rack
  class Cookieless
    def initialize(app, options={})
      @app, @options = app, options
    end

    def call(env)
      # have cookies or not
      support_cookie = env["HTTP_COOKIE"].present?
      if support_cookie
        env["COOKIES_SUPPORTED"] = 'true'
        @app.call(env)
      else
        session_id, cookies = get_cookies_by_query(env["QUERY_STRING"], env) || get_cookies_by_query((URI.parse(env['HTTP_REFERER']).query rescue nil), env)
        env["COOKIES_SUPPORTED"] = 'false'
        if cookies
          env["HTTP_COOKIE"] = cookies 
        else
          # oddity when IE hits 'www' site for first time
          # since env['HTTP_COOKIE'] is not set yet, we fall through into the
          # 'cookies not supported' part of the outside if..else
          # because it's 'www', our application_controller does not set any 
          # company subdomain cookie, so we effectively have no cookies set, so
          # we end up inside this else. we need set *something* so IE will actually
          # *have* a cookie for the next request, even if its crap.
          env["HTTP_COOKIE"] = "bugfix=true"
        end

        status, header, response = @app.call(env)

        if env['action_dispatch.request.path_parameters'] && %w(css js xml).exclude?(env['action_dispatch.request.path_parameters'][:format].to_s)
          session_id = save_cookies_by_session_id(env['rack.session.options'][:id] ||env["rack.session"]["session_id"] ||  session_id, env, header["Set-Cookie"])
          ## fix 3xx redirect
          header["Location"] = convert_url(header["Location"], session_id, env) if header["Location"]
          ## only process html page
          if header['Content-Type'].to_s.downcase.include?('html')
            if response.respond_to?(:body)
              response.body = process_body(response.body, session_id, env)
            elsif response.is_a?(Array) and [ActionView::OutputBuffer,String].detect{|klass| response[0].is_a?(klass)}
              response[0] = process_body(response[0].to_s, session_id, env)
            end
          end
        end
        [status, header, response]
      end
    end

    private
    def cache_store
      @options[:cache_store] || Rails.cache
    end

    def session_key
      (@options[:session_id] || :session_id).to_s
    end

    def get_cookies_by_query(query, env)
      session_id = Rack::Utils.parse_query(query, "&")[session_key].to_s
      return nil if session_id.blank?

      cache_id = generate_cookie_id(session_id, env)
      return nil unless session_id.present? and Rails.cache.exist?(cache_id)
      return [session_id, cache_store.read(cache_id)]
    end

    def save_cookies_by_session_id(session_id, env, cookie)
      cache_store.write(generate_cookie_id(session_id, env), cookie)
      session_id
    end

    def generate_cookie_id(session_id, env)
      Digest::SHA1.hexdigest(session_id.to_s + env["HTTP_USER_AGENT"].to_s + env["REMOTE_ADDR"].to_s)
    end

    def process_body(body, session_id, env)
      body_doc = Nokogiri::HTML(body)
      body_doc.css("a").map { |a| a["href"] = convert_url(a['href'], session_id, env) if a["href"] }
      body_doc.css("form").map do |form|
        # ensure we don't bother with 'si' stuff on external links/posts
        if form["action"] && (URI.parse(form["action"]).host =~ /completebook/i || URI.parse(form["action"]).host.nil?)
          form["action"] = convert_url(form["action"], session_id, env)
          form.add_child("<input type='hidden' name='#{session_key}' value='#{session_id}'>")
        end
      end
      body_doc.to_html
    end

    def convert_url(u, session_id, env)
      begin
        # ensure we don't bother with 'si' stuff on external links/posts
        return u unless URI.parse(u).host =~ /completebook/i || URI.parse(u).host.nil?
        anchor = URI.parse(u).fragment
        without_anchor = u.split('#').first
        return u if (without_anchor.respond_to?(:empty?) ? without_anchor.empty? : !without_anchor)
        u = URI.parse(URI.escape(without_anchor))
        blank_scheme = u.scheme.respond_to?(:empty?) ? u.scheme.empty? : !u.scheme
        u.query = Rack::Utils.build_query(Rack::Utils.parse_nested_query(u.query).merge({session_key => session_id})) if blank_scheme || u.scheme.to_s =~ /http/
        u = URI.unescape(u.to_s)
        u += "##{anchor.to_s}" if anchor
        u        
      rescue Exception => e
        # couldn't parse this url. probably invalid. just bail out and return it as-is
        return u
      end
    end
  end
end
