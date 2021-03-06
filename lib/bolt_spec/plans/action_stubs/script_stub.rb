# frozen_string_literal: true

module BoltSpec
  module Plans
    class ScriptStub < ActionStub
      def matches(targets, _script, arguments, options)
        if @invocation[:targets] && Set.new(@invocation[:targets]) != Set.new(targets.map(&:name))
          return false
        end

        if @invocation[:arguments] && arguments != @invocation[:arguments]
          return false
        end

        if @invocation[:options] && options != @invocation[:options]
          return false
        end

        true
      end

      def call(targets, script, arguments, options)
        @calls += 1
        if @return_block
          # Merge arguments and options into params to match puppet function signature.
          params = options.merge('arguments' => arguments)
          check_resultset(@return_block.call(targets: targets, script: script, params: params), script)
        else
          Bolt::ResultSet.new(targets.map { |target| @data[target.name] || default_for(target) })
        end
      end

      def parameters
        @invocation[:arguments] + @invocation[:options] if @invocation.include[:arguments]
      end

      def result_for(target, stdout: '', stderr: '')
        Bolt::Result.for_command(target, stdout, stderr, 0, 'script', '')
      end

      # Public methods

      def with_params(params)
        @invocation[:arguments] = params['arguments']
        @invocation[:options] = params.select { |k, _v| k.start_with?('_') }
        self
      end
    end
  end
end
