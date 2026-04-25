# frozen_string_literal: true

require "sketchup.rb"

module SistemaMEP
  module Loader
    module_function

    def load_files!
      puts "[SistemaMEP::Loader] ========================================"
      puts "[SistemaMEP::Loader] Iniciando carregamento dos módulos..."
      puts "[SistemaMEP::Loader] __FILE__ = #{__FILE__}"
      puts "[SistemaMEP::Loader] __dir__  = #{__dir__}"
      puts "[SistemaMEP::Loader] ========================================"

      begin
        require_relative "model_loader"
        puts "[SistemaMEP::Loader] ✅ model_loader.rb carregado"

        require_relative "pipe_builder"
        puts "[SistemaMEP::Loader] ✅ pipe_builder.rb carregado"

        require_relative "fitting_builder"
        puts "[SistemaMEP::Loader] ✅ fitting_builder.rb carregado"

        puts "[SistemaMEP::Loader] ✅ Todos os módulos carregados com sucesso!"
        true
      rescue Exception => e
        puts "[SistemaMEP::Loader] ❌ ERRO CRÍTICO ao carregar módulos:"
        puts "[SistemaMEP::Loader]    Classe: #{e.class}"
        puts "[SistemaMEP::Loader]    Mensagem: #{e.message}"
        puts "[SistemaMEP::Loader]    Backtrace:"
        e.backtrace.each { |line| puts "[SistemaMEP::Loader]      #{line}" }
        
        UI.messagebox(
          "#{SistemaMEP::PLUGIN_NAME}\n\n" \
          "ERRO ao carregar módulos:\n\n" \
          "#{e.class}: #{e.message}\n\n" \
          "Veja Ruby Console para detalhes.",
          MB_OK
        )
        false
      end
    end

    def create_menu!
      puts "[SistemaMEP::Loader] Criando menu..."

      begin
        ext_menu = UI.menu("Extensions")
        submenu  = ext_menu.add_submenu(SistemaMEP::PLUGIN_NAME)

        # Item 1: Criar Pipe (FUNCIONALIDADE PRINCIPAL)
        submenu.add_item("Criar Pipe") do
          puts "[SistemaMEP] Menu clicado: Criar Pipe"
          create_pipe_at_origin
        end

        submenu.add_separator

        # Item 2: Debug - Informações
        submenu.add_item("Debug: Informações do Sistema") do
          show_debug_info
        end

        # Item 3: Debug - Testar ModelLoader
        submenu.add_item("Debug: Testar ModelLoader") do
          test_model_loader
        end

        # Item 4: Debug - Listar Modelos
        submenu.add_item("Debug: Listar Todos os Modelos") do
          list_all_models
        end

        puts "[SistemaMEP::Loader] ✅ Menu criado com sucesso!"
        true
      rescue Exception => e
        puts "[SistemaMEP::Loader] ❌ ERRO ao criar menu:"
        puts "[SistemaMEP::Loader]    #{e.class}: #{e.message}"
        e.backtrace.each { |line| puts "[SistemaMEP::Loader]      #{line}" }
        
        UI.messagebox(
          "#{SistemaMEP::PLUGIN_NAME}\n\n" \
          "ERRO ao criar menu:\n\n" \
          "#{e.class}: #{e.message}",
          MB_OK
        )
        false
      end
    end

    # FUNCIONALIDADE PRINCIPAL: Criar pipe na origem
    def create_pipe_at_origin
      puts "[SistemaMEP] ========================================"
      puts "[SistemaMEP] Criando pipe na origem..."

      begin
        # Carregar modelo
        definition = SistemaMEP::ModelLoader.get_model("VBO_PIPE_MET")

        unless definition
          UI.messagebox(
            "❌ Falha ao carregar modelo VBO_PIPE_MET.skp\n\n" \
            "Verifique se o arquivo existe em:\n" \
            "sistema_mep/data/models/Basic Metal Piping/",
            MB_OK
          )
          return
        end

        # Inserir no modelo
        model = Sketchup.active_model
        model.start_operation("Criar Pipe MEP", true)

        transformation = Geom::Transformation.new(ORIGIN)
        instance = model.active_entities.add_instance(definition, transformation)
        
        # Adicionar atributos
        instance.set_attribute("SistemaMEP", "type", "pipe")
        instance.set_attribute("SistemaMEP", "created_at", Time.now.to_s)

        model.commit_operation

        puts "[SistemaMEP] ✅ Pipe criado com sucesso!"
        UI.messagebox(
          "✅ Pipe inserido na origem!\n\n" \
          "Modelo: #{definition.name}\n" \
          "Instâncias: #{definition.count_instances}",
          MB_OK
        )
      rescue Exception => e
        Sketchup.active_model.abort_operation
        puts "[SistemaMEP] ❌ ERRO ao criar pipe:"
        puts "[SistemaMEP]    #{e.class}: #{e.message}"
        e.backtrace.each { |line| puts "[SistemaMEP]      #{line}" }
        
        UI.messagebox(
          "❌ Erro ao criar pipe:\n\n#{e.message}",
          MB_OK
        )
      end
    end

    # Debug: Informações do sistema
    def show_debug_info
      puts "[SistemaMEP] Coletando informações de debug..."

      info = []
      info << "Sistema MEP Pro v#{SistemaMEP::VERSION}"
      info << ""
      info << "Módulos Carregados:"
      info << "  ✅ ModelLoader: #{defined?(SistemaMEP::ModelLoader) ? 'SIM' : 'NÃO'}"
      info << "  ✅ PipeBuilder: #{defined?(SistemaMEP::PipeBuilder) ? 'SIM' : 'NÃO'}"
      info << "  ✅ FittingBuilder: #{defined?(SistemaMEP::FittingBuilder) ? 'SIM' : 'NÃO'}"
      info << ""
      info << "Cache ModelLoader:"
      info << "  Modelos em cache: #{SistemaMEP::ModelLoader.cache_size}"
      info << ""
      info << "Caminho de dados:"
      info << "  #{SistemaMEP::ModelLoader::DATA_PATH}"

      msg = info.join("\n")
      puts msg
      UI.messagebox(msg, MB_OK)
    end

    # Debug: Testar ModelLoader
    def test_model_loader
      puts "[SistemaMEP] Testando ModelLoader.get_model('VBO_PIPE_MET')..."

      begin
        definition = SistemaMEP::ModelLoader.get_model("VBO_PIPE_MET")

        if definition
          msg = "✅ ModelLoader funcionando!\n\n" \
                "Modelo: #{definition.name}\n" \
                "Entidades: #{definition.entities.length}\n" \
                "Instâncias: #{definition.count_instances}"
          puts "[SistemaMEP] #{msg}"
          UI.messagebox(msg, MB_OK)
        else
          msg = "❌ ModelLoader retornou nil\n\n" \
                "Modelo 'VBO_PIPE_MET' não foi carregado.\n" \
                "Veja Ruby Console para detalhes."
          puts "[SistemaMEP] #{msg}"
          UI.messagebox(msg, MB_OK)
        end
      rescue Exception => e
        puts "[SistemaMEP] ❌ EXCEÇÃO no teste:"
        puts "[SistemaMEP]    #{e.class}: #{e.message}"
        e.backtrace.each { |line| puts "[SistemaMEP]      #{line}" }
        
        UI.messagebox(
          "❌ Erro no teste:\n\n#{e.class}\n#{e.message}",
          MB_OK
        )
      end
    end

    # Debug: Listar todos os modelos
    def list_all_models
      puts "[SistemaMEP] Listando todos os modelos disponíveis..."

      begin
        models = SistemaMEP::ModelLoader.list_all_models

        if models.empty?
          msg = "⚠️ Nenhum modelo .skp encontrado!\n\n" \
                "Verifique a pasta:\n" \
                "sistema_mep/data/models/Basic Metal Piping/"
          UI.messagebox(msg, MB_OK)
          return
        end

        msg = "📦 Modelos Disponíveis (#{models.count}):\n\n"
        models.take(10).each do |name, info|
          msg += "• #{name}\n"
          msg += "  #{info[:size].round(2)} KB\n"
        end

        if models.count > 10
          msg += "\n... e mais #{models.count - 10} modelos.\n"
        end

        msg += "\nVeja Ruby Console para lista completa."

        puts "[SistemaMEP] Modelos encontrados:"
        models.each { |name, info| puts "[SistemaMEP]   #{name} (#{info[:size].round(2)} KB)" }

        UI.messagebox(msg, MB_MULTILINE)
      rescue Exception => e
        puts "[SistemaMEP] ❌ ERRO ao listar modelos:"
        puts "[SistemaMEP]    #{e.message}"
        UI.messagebox("Erro:\n#{e.message}", MB_OK)
      end
    end

    def setup!
      if file_loaded?(__FILE__)
        puts "[SistemaMEP::Loader] ⚠️ Plugin já carregado (file_loaded? = true)"
        return
      end

      puts "[SistemaMEP::Loader] ========================================"
      puts "[SistemaMEP::Loader] Iniciando setup do plugin..."
      puts "[SistemaMEP::Loader] ========================================"

      ok_files = load_files!
      ok_menu  = create_menu!

      puts "[SistemaMEP::Loader] ========================================"
      puts "[SistemaMEP::Loader] Status do setup:"
      puts "[SistemaMEP::Loader]   Módulos: #{ok_files ? '✅' : '❌'}"
      puts "[SistemaMEP::Loader]   Menu: #{ok_menu ? '✅' : '❌'}"
      puts "[SistemaMEP::Loader] ========================================"

      file_loaded(__FILE__)

      if ok_files && ok_menu
        puts "[SistemaMEP::Loader] ✅ Plugin inicializado com SUCESSO!"
      else
        puts "[SistemaMEP::Loader] ⚠️ Plugin inicializado com AVISOS!"
      end
    end
  end
end

# BOOTSTRAP - Ponto de entrada
SistemaMEP::Loader.setup!