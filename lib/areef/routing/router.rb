module Areef
  module Routing
    class Router

      [:get, :post, :put, :patch, :delete].each do |method_name|
        define_method(method_name) do |path, to:|
          path = "/#{path}" unless path[0] = "/"
          klass_and_method = controller_and_action_for(to)
          @route_data = { path: path,
                          pattern: pattern_for(path),
                          klass_and_method: klass_and_method
                        }
          endpoints[method_name] << @route_data
        end
      end

      def draw(&block)
        instance_eval(&block)
      end

      def root(to)
        get "/", to: to
      end

      def resources(args)
        args = args.to_s
        get("/#{args}", to: "#{args}#index")
        get("/#{args}/new", to: "#{args}#new")
        get("/#{args}/:id", to: "#{args}#show")
        get("/#{args}/edit/:id", to: "#{args}#edit")
        delete("/#{args}/:id", to: "#{args}#destroy")
        post("/#{args}", to: "#{args}#create")
        put("/#{args}/:id", to: "#{args}#update")
      end

      def endpoints
        @endpoints ||= Hash.new { |hash, key| hash[key] = [] }
      end

      private

      def pattern_for(path)
        placeholders = []
        regex_part = path.gsub(/(:\w+)/) do |match|
          placeholders << match[1..-1].freeze
          "(?<#{placeholders.last}>[^/?#]+)"
        end
        [/^#{regex_part}$/, placeholders]
      end

      def controller_and_action_for(path_to)
        controller_path, action = path_to.split("#")
        controller = "#{controller_path.capitalize}Controller"
        [controller, action.to_sym]
      end
    end
  end
end
