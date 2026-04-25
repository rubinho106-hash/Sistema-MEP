# frozen_string_literal: true
# encoding: UTF-8

require "sketchup.rb"
require "extensions.rb"

module SistemaMEP
  PLUGIN_NAME = "Sistema MEP Pro"
  VERSION     = "1.0.0"
end

unless file_loaded?(__FILE__)
  loader_path = File.join(__dir__, "sistema_mep", "loader.rb")

  ex = SketchupExtension.new(
    SistemaMEP::PLUGIN_NAME,
    loader_path
  )

  ex.description = "Sistema MEP Pro para geracao automatica de tubulacoes MEP"
  ex.version     = SistemaMEP::VERSION
  ex.creator     = "Rubens"
  ex.copyright   = "2026 Sistema MEP Team"

  Sketchup.register_extension(ex, true)

  file_loaded(__FILE__)
end