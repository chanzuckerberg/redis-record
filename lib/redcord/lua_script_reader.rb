# frozen_string_literal: true

# typed: strict

require 'erb'

module Redcord::LuaScriptReader
  extend T::Sig

  sig { params(script_name: String).returns(String) }
  def self.read_lua_script(script_name)
    path = File.join(
      File.dirname(__FILE__),
      "server_scripts/#{script_name}.erb.lua",
    )
    ERB.new(File.read(path)).result(binding)
  end

  sig { params(relative_path: String).returns(String) }
  def self.include_lua(relative_path)
    path = File.join(
      File.dirname(__FILE__),
      "server_scripts/#{relative_path}.erb.lua",
    )
    File.read(path)
  end
end
