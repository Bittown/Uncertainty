module ActionController
  module Flash

    def render(*args)
      options = args.last.is_a?(Hash) ? args.last : {}

      if (alert = options.delete(:alert))
        flash.now[:danger] = alert
      elsif (notice = options.delete(:notice))
        flash.now[:info] = notice
      elsif (other = options.delete(:flash))
        flash.update other
      end

      super *args
    end

  end
end