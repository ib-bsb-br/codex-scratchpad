  <purpose>
    Você é um auditor de dados especializado em lógica temporal. Sua tarefa é comparar dois conjuntos de dados em pt-BR:
    (A) [[knowledge_first_set_ptbr]]: texto linha-por-linha (uma ocorrência por linha), onde cada linha deve gerar um intervalo de datas verificável; e
    (B) [[knowledge_second_set_json_ptbr]]: JSON estruturado, onde cada registro define um intervalo fechado entre "Início" e "Fim".
    Você deve extrair intervalos, normalizar datas para ISO (YYYY-MM-DD), validar consistência (Início <= Fim) e identificar todas as colisões (sobreposições) entre A e B.
    O resultado DEVE ser um relatório auditável em JSON, preservando os valores originais e listando erros de parsing/validação sem inventar dados.
  </purpose>

  <context>
    <language>pt-BR</language>

    <date_parsing_policy>
      <supported_formats_dataset_a>
        <format>dd/mm/aaaa (ex.: 10/01/2025)</format>
        <format>dd-mm-aaaa (ex.: 10-01-2025)</format>
        <format>aaaa-mm-dd (ex.: 2025-01-10)</format>
        <format>dd/mm/aa (ex.: 10/01/25) — somente se inequívoco; caso contrário, erro</format>
        <format>dd de &lt;mês&gt; de aaaa (ex.: 10 de janeiro de 2025)</format>
      </supported_formats_dataset_a>

      <single_date_policy>[[single_date_policy]]</single_date_policy>
      <single_date_policy_default_if_missing>one_day</single_date_policy_default_if_missing>
      <single_date_policy_definitions>
        <one_day>Uma única data inequívoca vira intervalo de 1 dia (Início = Fim).</one_day>
        <error_on_open_ended>Se a linha sugerir intervalo em aberto (ex.: "desde", "a partir de"), trate como erro (fim ausente).</error_on_open_ended>
      </single_date_policy_definitions>

      <timezone>[[date_timezone]]</timezone>
      <timezone_default_if_missing>America/Sao_Paulo</timezone_default_if_missing>
    </date_parsing_policy>

    <overlap_definition>
      <overlap_rule>[[overlap_rule]]</overlap_rule>
      <overlap_rule_default_if_missing>inclusive</overlap_rule_default_if_missing>
      <inclusive_rule_definition>
        Dois intervalos fechados [a_inicio, a_fim] e [b_inicio, b_fim] colidem se max(a_inicio, b_inicio) &lt;= min(a_fim, b_fim).
      </inclusive_rule_definition>
    </overlap_definition>

    <constraints>
      <constraint>Não inventar dados. Se faltar informação para extrair um intervalo, registrar erro e NÃO adivinhar.</constraint>
      <constraint>Saída FINAL deve ser somente JSON válido (sem Markdown, sem texto extra).</constraint>
      <constraint>Preservar valores originais (linha original; valores originais de "Início"/"Fim") e armazenar versões normalizadas em ISO.</constraint>
      <constraint>Todo item (linha de A e registro de B) deve aparecer no relatório: como "parsed" ou em "errors". Nada pode ser descartado silenciosamente.</constraint>
      <constraint>Se um intervalo for inválido (Início &gt; Fim), registrar erro e excluir esse item da checagem de colisões.</constraint>
    </constraints>
  </context>

  <input_data>
    <knowledge_first_set_ptbr>
    [[knowledge_first_set_ptbr]]
```knowledge_first_set_ptbr
O serviço do servidor A. Castro do dia 17/04/2025 foi alterado. Novo período: 18/04/2025 10:00 a 19/04/2025 10:00. Permuta com Colafranceschi.
O serviço do servidor A. Castro do dia 20/03/2025 foi alterado. Novo período: 21/03/2025 10:00 a 22/03/2025 10:00. Permuta com Colafranceschi.
O serviço do servidor A. Castro do dia 20/06/2025 foi alterado. Novo período: 21/06/2025 10:00 a 22/06/2025 10:00. Permuta com Guilherme Carvalho.
O serviço do servidor A. Castro do dia 24/02/2025 foi alterado. Novo período: 22/02/2025 10:00 a 23/02/2025 10:00. Permuta com Marcio Araujo.
O serviço do servidor Adauto Moreira de 15/12/2025 10:00 foi alterado(a). Novo período: 14/12/2025 10:00 a 15/12/2025 10:00.
O serviço do servidor Adauto Moreira de 20/10/2025 10:00 foi alterado(a). Novo período: 19/10/2025 10:00 a 20/10/2025 10:00.
O serviço do servidor Adauto Moreira do dia 02/12/2025 foi alterado. Novo período: 03/12/2025 09:00 a 04/12/2025 09:00. Permuta com Scalia.
O serviço do servidor Ana Ramos de 30/10/2025 10:00 foi alterado(a). Novo período: 31/10/2025 10:00 a 01/11/2025 10:00.
O serviço do servidor Ana Ramos de 31/10/2025 10:00 foi alterado(a). Novo período: 30/10/2025 10:00 a 31/10/2025 10:00.
O serviço do servidor Ana Ramos do dia 13/12/2025 foi alterado. Novo período: 12/12/2025 10:00 a 13/12/2025 10:00. Permuta com Trevizolo.
O serviço do servidor Ana Ramos do dia 23/11/2025 foi alterado. Novo período: 19/12/2025 10:00 a 20/12/2025 10:00, na UOP UOP02-DEL03-DF. Permuta com Andre Araujo.
O serviço do servidor Andre Araujo do dia 19/12/2025 foi alterado. Novo período: 23/11/2025 10:00 a 24/11/2025 10:00, na UOP UOP02-DEL03-DF. Permuta com Ana Ramos.
O serviço do servidor Andre Araujo do dia 29/11/2025 foi alterado. Novo período: 30/11/2025 10:00 a 01/12/2025 10:00. Permuta com C. Brito.
O serviço do servidor Augusto Ribeiro do dia 01/03/2025 foi alterado. Novo período: 02/03/2025 09:00 a 03/03/2025 09:00. Permuta com Honorato.
O serviço do servidor Augusto Ribeiro do dia 05/02/2025 foi alterado. Novo período: 06/02/2025 09:00 a 07/02/2025 09:00. Permuta com Honorato.
O serviço do servidor Augusto Ribeiro do dia 14/12/2025 foi alterado. Novo período: 15/12/2025 09:00 a 16/12/2025 09:00. Permuta com Honorato.
O serviço do servidor Augusto Ribeiro do dia 25/02/2025 foi alterado. Novo período: 26/02/2025 09:00 a 27/02/2025 09:00. Permuta com Augustus Cutrim.
O serviço do servidor Augusto Ribeiro do dia 25/02/2025 foi alterado. Novo período: 26/02/2025 09:00 a 27/02/2025 09:00. Permuta com Augustus Cutrim.
O serviço do servidor Augusto Ribeiro do dia 26/02/2025 foi alterado. Novo período: 25/02/2025 09:00 a 26/02/2025 09:00. Permuta com Augustus Cutrim.
O serviço do servidor Augusto Ribeiro do dia 28/11/2025 foi alterado. Novo período: 29/11/2025 09:00 a 30/11/2025 09:00. Permuta com Scalia.
O serviço do servidor Augustus Cutrim de 09/01/2025 09:00 foi alterado(a). Novo período: 10/01/2025 09:00 a 11/01/2025 09:00.
O serviço do servidor Augustus Cutrim de 17/01/2025 09:00 foi alterado(a). Novo período: 16/01/2025 09:00 a 17/01/2025 09:00.
O serviço do servidor Augustus Cutrim de 18/06/2025 09:00 foi alterado(a). Novo período: 22/06/2025 09:00 a 23/06/2025 09:00.
O serviço do servidor Augustus Cutrim do dia 01/05/2025 foi alterado. Novo período: 30/04/2025 09:00 a 01/05/2025 09:00, na UOP UOP01-DEL03-DF. Permuta com Judivan.
O serviço do servidor Augustus Cutrim do dia 01/05/2025 foi alterado. Novo período: 30/04/2025 09:00 a 01/05/2025 09:00, na UOP UOP01-DEL03-DF. Permuta com Judivan.
O serviço do servidor Augustus Cutrim do dia 01/07/2025 foi alterado. Novo período: 02/07/2025 09:00 a 03/07/2025 09:00. Permuta com Leandro Regis.
O serviço do servidor Augustus Cutrim do dia 02/07/2025 foi alterado. Novo período: 30/07/2025 10:00 a 31/07/2025 10:00, na UOP UOP02-DEL03-DF. Permuta com Zardo.
O serviço do servidor Augustus Cutrim do dia 06/06/2025 foi alterado. Novo período: 05/06/2025 09:00 a 06/06/2025 09:00. Permuta com Osmar Cardoso.
O serviço do servidor Augustus Cutrim do dia 22/02/2025 foi alterado. Novo período: 08/02/2025 09:00 a 09/02/2025 09:00. Permuta com Cavadas.
O serviço do servidor Augustus Cutrim do dia 25/02/2025 foi alterado. Novo período: 26/02/2025 09:00 a 27/02/2025 09:00. Permuta com Augusto Ribeiro.
O serviço do servidor Augustus Cutrim do dia 26/02/2025 foi alterado. Novo período: 25/02/2025 09:00 a 26/02/2025 09:00. Permuta com Augusto Ribeiro.
O serviço do servidor Augustus Cutrim do dia 26/02/2025 foi alterado. Novo período: 25/02/2025 09:00 a 26/02/2025 09:00. Permuta com Augusto Ribeiro.
O serviço do servidor Augustus Cutrim do dia 30/04/2025 foi alterado. Novo período: 01/05/2025 09:00 a 02/05/2025 09:00, na UOP UOP01-DEL03-DF. Permuta com Judivan.
O serviço do servidor B. Simoes de 15/11/2025 10:00 foi alterado(a). Novo período: 16/11/2025 10:00 a 17/11/2025 10:00.
O serviço do servidor B. Simoes do dia 16/11/2025 foi alterado. Novo período: 14/11/2025 10:00 a 15/11/2025 10:00. Permuta com Trevizolo.
O serviço do servidor Cavadas de 14/10/2025 09:00 foi alterado(a). Novo período: 13/10/2025 09:00 a 14/10/2025 09:00.
O serviço do servidor Cavadas do dia 08/02/2025 foi alterado. Novo período: 22/02/2025 09:00 a 23/02/2025 09:00. Permuta com Augustus Cutrim.
O serviço do servidor Cavadas do dia 23/11/2025 foi alterado. Novo período: 22/11/2025 09:00 a 23/11/2025 09:00. Permuta com M. Nogueira.
O serviço do servidor C. Brito de 17/01/2025 10:00 foi alterado(a). Novo período: 18/01/2025 10:00 a 19/01/2025 10:00.
O serviço do servidor C. Brito de 18/01/2025 10:00 foi alterado(a). Novo período: 17/01/2025 10:00 a 18/01/2025 10:00.
O serviço do servidor C. Brito do dia 29/07/2025 foi alterado. Novo período: 28/07/2025 10:00 a 29/07/2025 10:00. Permuta com Osni Santos.
O serviço do servidor C. Brito do dia 30/11/2025 foi alterado. Novo período: 29/11/2025 10:00 a 30/11/2025 10:00. Permuta com Andre Araujo.
O serviço do servidor C. Neri de 02/01/2025 10:00 foi alterado(a). Novo período: 03/01/2025 10:00 a 04/01/2025 10:00.
O serviço do servidor C. Neri de 06/01/2025 10:00 foi alterado(a). Novo período: 07/01/2025 10:00 a 08/01/2025 10:00.
O serviço do servidor C. Neri de 27/09/2025 10:00 foi alterado(a). Novo período: 26/09/2025 10:00 a 27/09/2025 10:00.
O serviço do servidor C. Neri do dia 07/03/2025 foi alterado. Novo período: 08/03/2025 10:00 a 09/03/2025 10:00. Permuta com W. Costa.
O serviço do servidor C. Neri do dia 17/07/2025 foi alterado. Novo período: 23/07/2025 10:00 a 24/07/2025 10:00. Permuta com Colafranceschi.
O serviço do servidor Colafranceschi de 03/07/2025 10:00 foi alterado(a). Novo período: 05/07/2025 10:00 a 06/07/2025 10:00.
O serviço do servidor Colafranceschi de 12/01/2025 10:00 foi alterado(a). Novo período: 14/01/2025 10:00 a 15/01/2025 10:00.
O serviço do servidor Colafranceschi de 16/01/2025 10:00 foi alterado(a). Novo período: 17/01/2025 10:00 a 18/01/2025 10:00.
O serviço do servidor Colafranceschi de 27/07/2025 10:00 foi alterado(a). Novo período: 26/07/2025 10:00 a 27/07/2025 10:00.
O serviço do servidor Colafranceschi do dia 10/12/2025 foi alterado. Novo período: 11/12/2025 10:00 a 12/12/2025 10:00. Permuta com Mário Seixas.
O serviço do servidor Colafranceschi do dia 18/04/2025 foi alterado. Novo período: 17/04/2025 10:00 a 18/04/2025 10:00. Permuta com A. Castro.
O serviço do servidor Colafranceschi do dia 21/02/2025 foi alterado. Novo período: 07/02/2025 10:00 a 08/02/2025 10:00. Permuta com Pereira II.
O serviço do servidor Colafranceschi do dia 21/03/2025 foi alterado. Novo período: 20/03/2025 10:00 a 21/03/2025 10:00. Permuta com A. Castro.
O serviço do servidor Colafranceschi do dia 23/07/2025 foi alterado. Novo período: 17/07/2025 10:00 a 18/07/2025 10:00. Permuta com C. Neri.
O serviço do servidor Colafranceschi do dia 29/03/2025 foi alterado. Novo período: 27/03/2025 09:00 a 28/03/2025 09:00, na UOP UOP01-DEL03-DF. Permuta com Shayron.
O serviço do servidor Costa Gomes de 03/04/2025 10:00 foi alterado(a). Novo período: 01/04/2025 10:00 a 02/04/2025 10:00.
O serviço do servidor Costa Gomes de 21/04/2025 10:00 foi alterado(a). Novo período: 23/04/2025 10:00 a 24/04/2025 10:00.
O serviço do servidor Costa Gomes de 28/06/2025 10:00 foi alterado(a). Novo período: 28/06/2025 10:00 a 29/06/2025 10:00.
O serviço do servidor Costa Gomes do dia 13/04/2025 foi alterado. Novo período: 14/04/2025 10:00 a 15/04/2025 10:00. Permuta com Shayron.
O serviço do servidor Costa Gomes do dia 15/04/2025 foi alterado. Novo período: 16/04/2025 10:00 a 17/04/2025 10:00. Permuta com W. Costa.
O serviço do servidor Diego Veloso de 02/09/2025 10:00 foi alterado(a). Novo período: 04/09/2025 10:00 a 05/09/2025 10:00.
O serviço do servidor Diego Veloso de 04/09/2025 10:00 foi alterado(a). Novo período: 02/09/2025 10:00 a 03/09/2025 10:00.
O serviço do servidor Diego Veloso do dia 25/12/2025 foi alterado. Novo período: 24/12/2025 10:00 a 25/12/2025 10:00. Permuta com Trevizolo.
O serviço do servidor Estelles de 26/04/2025 09:00 foi alterado(a). Novo período: 28/04/2025 09:00 a 29/04/2025 09:00.
O serviço do servidor Estelles de 30/04/2025 09:00 foi alterado(a). Novo período: 24/04/2025 09:00 a 25/04/2025 09:00.
O serviço do servidor Estelles do dia 01/02/2025 foi alterado. Novo período: 30/01/2025 09:00 a 31/01/2025 09:00, na UOP UOP01-DEL03-DF. Permuta com Osmar Cardoso.
O serviço do servidor Estelles do dia 12/11/2025 foi alterado. Novo período: 13/11/2025 09:00 a 14/11/2025 09:00. Permuta com Zardo.
O serviço do servidor Estelles do dia 17/06/2025 foi alterado. Novo período: 18/06/2025 09:00 a 19/06/2025 09:00. Permuta com Mayara.
O serviço do servidor Estelles do dia 21/02/2025 foi alterado. Novo período: 23/02/2025 09:00 a 24/02/2025 09:00. Permuta com Osmar Cardoso.
O serviço do servidor Estelles do dia 22/04/2025 foi alterado. Novo período: 21/04/2025 09:00 a 22/04/2025 09:00. Permuta com Leandro Regis.
O serviço do servidor F. Camarinha de 08/06/2025 09:00 foi alterado(a). Novo período: 28/06/2025 09:00 a 29/06/2025 09:00.
O serviço do servidor F. Camarinha de 28/06/2025 09:00 foi alterado(a). Novo período: 04/06/2025 09:00 a 05/06/2025 09:00.
O serviço do servidor F. Dantas de 02/09/2025 10:00 foi alterado(a). Novo período: 04/09/2025 10:00 a 05/09/2025 10:00.
O serviço do servidor F. Dantas de 04/09/2025 10:00 foi alterado(a). Novo período: 02/09/2025 10:00 a 03/09/2025 10:00.
O serviço do servidor F. Dantas de 05/12/2025 10:00 foi alterado(a). Novo período: 06/12/2025 10:00 a 07/12/2025 10:00.
O serviço do servidor F. Dantas de 07/08/2025 10:00 foi alterado(a). Novo período: 06/08/2025 10:00 a 07/08/2025 10:00.
O serviço do servidor F. Dantas de 08/09/2025 10:00 foi alterado(a). Novo período: 10/09/2025 10:00 a 11/09/2025 10:00.
O serviço do servidor F. Dantas de 08/10/2025 10:00 foi alterado(a). Novo período: 09/10/2025 10:00 a 10/10/2025 10:00.
O serviço do servidor F. Dantas de 09/10/2025 10:00 foi alterado(a). Novo período: 08/10/2025 10:00 a 09/10/2025 10:00.
O serviço do servidor F. Dantas de 10/10/2025 10:00 foi alterado(a). Novo período: 09/10/2025 10:00 a 10/10/2025 10:00.
O serviço do servidor F. Dantas de 13/08/2025 10:00 foi alterado(a). Novo período: 14/08/2025 10:00 a 15/08/2025 10:00.
O serviço do servidor F. Dantas de 13/10/2025 10:00 foi alterado(a). Novo período: 14/10/2025 10:00 a 15/10/2025 10:00.
O serviço do servidor F. Dantas de 14/10/2025 10:00 foi alterado(a). Novo período: 13/10/2025 10:00 a 14/10/2025 10:00.
O serviço do servidor F. Dantas de 15/08/2025 10:00 foi alterado(a). Novo período: 13/08/2025 10:00 a 14/08/2025 10:00.
O serviço do servidor F. Dantas de 15/11/2025 10:00 foi alterado(a). Novo período: 15/11/2025 10:00 a 16/11/2025 10:00.
O serviço do servidor F. Dantas de 19/08/2025 10:00 foi alterado(a). Novo período: 18/08/2025 10:00 a 19/08/2025 10:00.
O serviço do servidor F. Dantas de 27/08/2025 10:00 foi alterado(a). Novo período: 26/08/2025 10:00 a 27/08/2025 10:00.
O serviço do servidor F. Dantas de 30/10/2025 10:00 foi alterado(a). Novo período: 29/10/2025 10:00 a 30/10/2025 10:00.
O serviço do servidor F. Dantas do dia 10/12/2025 foi alterado. Novo período: 04/12/2025 10:00 a 05/12/2025 10:00, na UOP UOP02-DEL03-DF. Permuta com Trevizolo.
O serviço do servidor F. Dantas do dia 13/12/2025 foi alterado. Novo período: 19/12/2025 10:00 a 20/12/2025 10:00. Permuta com Mário Seixas.
O serviço do servidor F. Dantas do dia 19/12/2025 foi alterado. Novo período: 13/12/2025 10:00 a 14/12/2025 10:00. Permuta com Mário Seixas cancelada.
O serviço do servidor F. Dantas do dia 26/10/2025 foi alterado. Novo período: 25/10/2025 10:00 a 26/10/2025 10:00. Permuta com Lucas Barros.
O serviço do servidor F. Lopes de 04/09/2025 10:00 foi alterado(a). Novo período: 02/09/2025 10:00 a 03/09/2025 10:00.
O serviço do servidor F. Lopes do dia 22/10/2025 foi alterado. Novo período: 20/10/2025 10:00 a 21/10/2025 10:00. Permuta com Mário Seixas.
O serviço do servidor F. Lopes do dia 24/09/2025 foi alterado. Novo período: 23/09/2025 09:00 a 24/09/2025 09:00. Permuta com Lucas Campos.
O serviço do servidor Guilherme Carvalho de 02/04/2025 10:00 foi alterado(a). Novo período: 02/04/2025 10:00 a 03/04/2025 10:00.
O serviço do servidor Guilherme Carvalho de 22/12/2025 10:00 foi alterado(a). Novo período: 23/12/2025 10:00 a 24/12/2025 10:00.
O serviço do servidor Guilherme Carvalho do dia 21/06/2025 foi alterado. Novo período: 20/06/2025 10:00 a 21/06/2025 10:00. Permuta com A. Castro.
O serviço do servidor Henriques Neto do dia 29/12/2025 foi alterado. Novo período: 27/12/2025 09:00 a 28/12/2025 09:00. Permuta com Mayara.
O serviço do servidor Honorato do dia 02/03/2025 foi alterado. Novo período: 01/03/2025 09:00 a 02/03/2025 09:00. Permuta com Augusto Ribeiro.
O serviço do servidor Honorato do dia 06/02/2025 foi alterado. Novo período: 05/02/2025 09:00 a 06/02/2025 09:00. Permuta com Augusto Ribeiro.
O serviço do servidor Honorato do dia 15/12/2025 foi alterado. Novo período: 14/12/2025 09:00 a 15/12/2025 09:00. Permuta com Augusto Ribeiro.
O serviço do servidor Jonas Felipe de 10/04/2025 09:00 foi alterado(a). Novo período: 10/04/2025 09:00 a 11/04/2025 09:00.
O serviço do servidor Jonas Felipe de 27/02/2025 10:00 foi alterado(a). Novo período: 28/02/2025 10:00 a 01/03/2025 10:00.
O serviço do servidor Jonas Felipe do dia 05/06/2025 foi alterado. Novo período: 19/06/2025 09:00 a 20/06/2025 09:00. Permuta com Osmar Cardoso.
O serviço do servidor Jonas Felipe do dia 18/04/2025 foi alterado. Novo período: 17/04/2025 09:00 a 18/04/2025 09:00. Permuta com Osmar Cardoso.
O serviço do servidor Jonas Felipe do dia 20/05/2025 foi alterado. Novo período: 30/05/2025 09:00 a 31/05/2025 09:00. Permuta com Lucas Campos.
O serviço do servidor Jonas Felipe do dia 26/12/2025 foi alterado. Novo período: 28/12/2025 09:00 a 29/12/2025 09:00. Permuta com Zardo.
O serviço do servidor Judivan do dia 01/05/2025 foi alterado. Novo período: 30/04/2025 09:00 a 01/05/2025 09:00, na UOP UOP01-DEL03-DF. Permuta com Augustus Cutrim.
O serviço do servidor Judivan do dia 24/05/2025 foi alterado. Novo período: 10/05/2025 09:00 a 11/05/2025 09:00. Permuta com Osmar Cardoso.
O serviço do servidor Judivan do dia 30/04/2025 foi alterado. Novo período: 01/05/2025 09:00 a 02/05/2025 09:00, na UOP UOP01-DEL03-DF. Permuta com Augustus Cutrim.
O serviço do servidor Judivan do dia 30/04/2025 foi alterado. Novo período: 01/05/2025 09:00 a 02/05/2025 09:00, na UOP UOP01-DEL03-DF. Permuta com Augustus Cutrim.
O serviço do servidor Juliana Moreira do dia 18/06/2025 foi alterado. Novo período: 19/06/2025 09:00 a 20/06/2025 09:00. Permuta com Mayara.
O serviço do servidor Leandro Regis de 06/07/2025 09:00 foi alterado(a). Novo período: 06/07/2025 09:00 a 07/07/2025 09:00.
O serviço do servidor Leandro Regis do dia 02/07/2025 foi alterado. Novo período: 01/07/2025 09:00 a 02/07/2025 09:00. Permuta com Augustus Cutrim.
O serviço do servidor Leandro Regis do dia 21/04/2025 foi alterado. Novo período: 22/04/2025 09:00 a 23/04/2025 09:00. Permuta com Estelles.
O serviço do servidor Leandro Regis do dia 30/07/2025 foi alterado. Novo período: 29/07/2025 09:00 a 30/07/2025 09:00. Permuta com Mayara.
O serviço do servidor Lucas Barros de 24/03/2025 10:00 foi alterado(a). Novo período: 23/03/2025 10:00 a 24/03/2025 10:00.
O serviço do servidor Lucas Barros do dia 25/10/2025 foi alterado. Novo período: 26/10/2025 10:00 a 27/10/2025 10:00. Permuta com F. Dantas.
O serviço do servidor Lucas Campos de 08/12/2025 09:00 foi alterado(a). Novo período: 09/12/2025 09:00 a 10/12/2025 09:00.
O serviço do servidor Lucas Campos do dia 23/09/2025 foi alterado. Novo período: 24/09/2025 09:00 a 25/09/2025 09:00. Permuta com F. Lopes.
O serviço do servidor Lucas Campos do dia 30/05/2025 foi alterado. Novo período: 20/05/2025 09:00 a 21/05/2025 09:00. Permuta com Jonas Felipe.
O serviço do servidor Marcio Araujo do dia 19/12/2025 foi alterado. Novo período: 18/12/2025 10:00 a 19/12/2025 10:00. Permuta com Victor Henrique.
O serviço do servidor Marcio Araujo do dia 22/02/2025 foi alterado. Novo período: 24/02/2025 10:00 a 25/02/2025 10:00. Permuta com A. Castro.
O serviço do servidor Mário Seixas de 29/09/2025 10:00 foi alterado(a). Novo período: 30/09/2025 10:00 a 01/10/2025 10:00.
O serviço do servidor Mário Seixas do dia 11/12/2025 foi alterado. Novo período: 10/12/2025 10:00 a 11/12/2025 10:00. Permuta com Colafranceschi.
O serviço do servidor Mário Seixas do dia 13/12/2025 foi alterado. Novo período: 19/12/2025 10:00 a 20/12/2025 10:00. Permuta com F. Dantas cancelada.
O serviço do servidor Mário Seixas do dia 17/11/2025 foi alterado. Novo período: 16/11/2025 10:00 a 17/11/2025 10:00. Permuta com Victor Henrique.
O serviço do servidor Mário Seixas do dia 19/12/2025 foi alterado. Novo período: 13/12/2025 10:00 a 14/12/2025 10:00. Permuta com F. Dantas.
O serviço do servidor Mário Seixas do dia 20/10/2025 foi alterado. Novo período: 22/10/2025 10:00 a 23/10/2025 10:00. Permuta com F. Lopes.
O serviço do servidor Mário Seixas do dia 29/11/2025 foi alterado. Novo período: 30/11/2025 10:00 a 01/12/2025 10:00. Permuta com Trevizolo.
O serviço do servidor Mayara de 13/10/2025 09:00 foi alterado(a). Novo período: 14/10/2025 09:00 a 15/10/2025 09:00.
O serviço do servidor Mayara de 14/08/2025 09:00 foi alterado(a). Novo período: 13/08/2025 09:00 a 14/08/2025 09:00.
O serviço do servidor Mayara de 18/01/2025 10:00 foi alterado(a). Novo período: 17/01/2025 10:00 a 18/01/2025 10:00.
O serviço do servidor Mayara de 28/12/2025 09:00 foi alterado(a). Novo período: 27/12/2025 09:00 a 28/12/2025 09:00.
O serviço do servidor Mayara do dia 13/07/2025 foi alterado. Novo período: 27/07/2025 10:00 a 28/07/2025 10:00, na UOP UOP02-DEL03-DF. Permuta com M. Nogueira.
O serviço do servidor Mayara do dia 18/06/2025 foi alterado. Novo período: 17/06/2025 09:00 a 18/06/2025 09:00. Permuta com Estelles.
O serviço do servidor Mayara do dia 19/06/2025 foi alterado. Novo período: 18/06/2025 09:00 a 19/06/2025 09:00. Permuta com Juliana Moreira.
O serviço do servidor Mayara do dia 27/12/2025 foi alterado. Novo período: 29/12/2025 09:00 a 30/12/2025 09:00. Permuta com Henriques Neto.
O serviço do servidor Mayara do dia 29/07/2025 foi alterado. Novo período: 30/07/2025 09:00 a 31/07/2025 09:00. Permuta com Leandro Regis.
O serviço do servidor M. Nogueira de 04/11/2025 09:00 foi alterado(a). Novo período: 06/11/2025 09:00 a 07/11/2025 09:00.
O serviço do servidor M. Nogueira de 06/11/2025 09:00 foi alterado(a). Novo período: 04/11/2025 09:00 a 05/11/2025 09:00.
O serviço do servidor M. Nogueira de 09/07/2025 09:00 foi alterado(a). Novo período: 08/07/2025 09:00 a 09/07/2025 09:00.
O serviço do servidor M. Nogueira de 26/11/2025 09:00 foi alterado(a). Novo período: 16/11/2025 09:00 a 17/11/2025 09:00.
O serviço do servidor M. Nogueira do dia 22/11/2025 foi alterado. Novo período: 23/11/2025 09:00 a 24/11/2025 09:00. Permuta com Cavadas.
O serviço do servidor M. Nogueira do dia 23/07/2025 foi alterado. Novo período: 17/07/2025 09:00 a 18/07/2025 09:00, na UOP UOP01-DEL03-DF. Permuta com Osmar Cardoso.
O serviço do servidor M. Nogueira do dia 27/07/2025 foi alterado. Novo período: 13/07/2025 09:00 a 14/07/2025 09:00, na UOP UOP01-DEL03-DF. Permuta com Mayara.
O serviço do servidor M. Nogueira do dia 28/12/2025 foi alterado. Novo período: 27/12/2025 09:00 a 28/12/2025 09:00. Permuta com Zardo.
O serviço do servidor Oliveira V de 04/02/2025 09:00 foi alterado(a). Novo período: 03/02/2025 09:00 a 04/02/2025 09:00.
O serviço do servidor Oliveira V de 04/06/2025 09:00 foi alterado(a). Novo período: 28/06/2025 09:00 a 29/06/2025 09:00.
O serviço do servidor Oliveira V de 28/06/2025 09:00 foi alterado(a). Novo período: 08/06/2025 09:00 a 09/06/2025 09:00.
O serviço do servidor Oliveira V do dia 28/06/2025 foi alterado. Novo período: 29/06/2025 10:00 a 30/06/2025 10:00, na UOP UOP02-DEL03-DF. Permuta com Pamela.
O serviço do servidor Osmar Cardoso de 04/12/2025 09:00 foi alterado(a). Novo período: 05/12/2025 09:00 a 06/12/2025 09:00.
O serviço do servidor Osmar Cardoso de 06/11/2025 09:00 foi alterado(a). Novo período: 04/11/2025 09:00 a 05/11/2025 09:00.
O serviço do servidor Osmar Cardoso de 16/04/2025 09:00 foi alterado(a). Novo período: 17/04/2025 09:00 a 18/04/2025 09:00.
O serviço do servidor Osmar Cardoso de 27/09/2025 09:00 foi alterado(a). Novo período: 26/09/2025 09:00 a 27/09/2025 09:00.
O serviço do servidor Osmar Cardoso do dia 05/06/2025 foi alterado. Novo período: 06/06/2025 09:00 a 07/06/2025 09:00. Permuta com Augustus Cutrim.
O serviço do servidor Osmar Cardoso do dia 10/05/2025 foi alterado. Novo período: 24/05/2025 09:00 a 25/05/2025 09:00. Permuta com Judivan.
O serviço do servidor Osmar Cardoso do dia 13/10/2025 foi alterado. Novo período: 12/10/2025 09:00 a 13/10/2025 09:00. Permuta com Scalia.
O serviço do servidor Osmar Cardoso do dia 17/04/2025 foi alterado. Novo período: 18/04/2025 09:00 a 19/04/2025 09:00. Permuta com Jonas Felipe.
O serviço do servidor Osmar Cardoso do dia 17/07/2025 foi alterado. Novo período: 23/07/2025 10:00 a 24/07/2025 10:00, na UOP UOP02-DEL03-DF. Permuta com M. Nogueira.
O serviço do servidor Osmar Cardoso do dia 18/11/2025 foi alterado. Novo período: 17/11/2025 09:00 a 18/11/2025 09:00. Permuta com Zardo.
O serviço do servidor Osmar Cardoso do dia 19/06/2025 foi alterado. Novo período: 05/06/2025 09:00 a 06/06/2025 09:00. Permuta com Jonas Felipe.
O serviço do servidor Osmar Cardoso do dia 23/02/2025 foi alterado. Novo período: 21/02/2025 09:00 a 22/02/2025 09:00. Permuta com Estelles.
O serviço do servidor Osmar Cardoso do dia 30/01/2025 foi alterado. Novo período: 01/02/2025 09:00 a 02/02/2025 09:00, na UOP UOP01-DEL03-DF. Permuta com Estelles.
O serviço do servidor Osni Santos do dia 28/07/2025 foi alterado. Novo período: 29/07/2025 10:00 a 30/07/2025 10:00. Permuta com C. Brito.
O serviço do servidor Pamela de 13/09/2025 10:00 foi alterado(a). Novo período: 12/09/2025 10:00 a 13/09/2025 10:00.
O serviço do servidor Pamela do dia 29/06/2025 foi alterado. Novo período: 28/06/2025 09:00 a 29/06/2025 09:00, na UOP UOP01-DEL03-DF. Permuta com Oliveira V.
O serviço do servidor Pereira II de 05/10/2025 10:00 foi alterado(a). Novo período: 05/10/2025 10:00 a 06/10/2025 10:00.
O serviço do servidor Pereira II de 10/04/2025 09:00 foi alterado(a). Novo período: 11/04/2025 09:00 a 12/04/2025 09:00.
O serviço do servidor Pereira II de 14/04/2025 09:00 foi alterado(a). Novo período: 14/04/2025 09:00 a 15/04/2025 09:00.
O serviço do servidor Pereira II de 26/12/2025 10:00 foi alterado(a). Novo período: 27/12/2025 10:00 a 28/12/2025 10:00.
O serviço do servidor Pereira II de 27/09/2025 10:00 foi alterado(a). Novo período: 28/09/2025 10:00 a 29/09/2025 10:00.
O serviço do servidor Pereira II do dia 07/02/2025 foi alterado. Novo período: 21/02/2025 10:00 a 22/02/2025 10:00. Permuta com Colafranceschi.
O serviço do servidor R. Duarte de 08/07/2025 10:00 foi alterado(a). Novo período: 09/07/2025 10:00 a 10/07/2025 10:00.
O serviço do servidor Regina Silveira de 12/01/2025 09:00 foi alterado(a). Novo período: 12/01/2025 09:00 a 13/01/2025 09:00.
O serviço do servidor Regina Silveira de 20/01/2025 09:00 foi alterado(a). Novo período: 19/01/2025 09:00 a 20/01/2025 09:00.
O serviço do servidor Scalia do dia 03/12/2025 foi alterado. Novo período: 02/12/2025 09:00 a 03/12/2025 09:00. Permuta com Adauto Moreira.
O serviço do servidor Scalia do dia 12/10/2025 foi alterado. Novo período: 13/10/2025 09:00 a 14/10/2025 09:00. Permuta com Osmar Cardoso.
O serviço do servidor Scalia do dia 29/11/2025 foi alterado. Novo período: 28/11/2025 09:00 a 29/11/2025 09:00. Permuta com Augusto Ribeiro.
O serviço do servidor Shayron do dia 14/04/2025 foi alterado. Novo período: 13/04/2025 10:00 a 14/04/2025 10:00. Permuta com Costa Gomes.
O serviço do servidor Shayron do dia 27/03/2025 foi alterado. Novo período: 29/03/2025 10:00 a 30/03/2025 10:00, na UOP UOP02-DEL03-DF. Permuta com Colafranceschi.
O serviço do servidor Tavares Junior de 19/05/2025 10:00 foi alterado(a). Novo período: 20/05/2025 10:00 a 21/05/2025 10:00.
O serviço do servidor Tavares Junior de 25/04/2025 10:00 foi alterado(a). Novo período: 24/04/2025 10:00 a 25/04/2025 10:00.
O serviço do servidor Tavares Junior de 27/05/2025 10:00 foi alterado(a). Novo período: 28/05/2025 10:00 a 29/05/2025 10:00.
O serviço do servidor Thiago Martins de 17/07/2025 09:00 foi alterado(a). Novo período: 16/07/2025 09:00 a 17/07/2025 09:00.
O serviço do servidor Thiago Martins de 24/04/2025 09:00 foi alterado(a). Novo período: 23/04/2025 09:00 a 24/04/2025 09:00.
O serviço do servidor Thiago Martins de 29/07/2025 09:00 foi alterado(a). Novo período: 28/07/2025 09:00 a 29/07/2025 09:00.
O serviço do servidor Trevizolo de 02/11/2025 10:00 foi alterado(a). Novo período: 01/11/2025 10:00 a 02/11/2025 10:00.
O serviço do servidor Trevizolo de 09/10/2025 10:00 foi alterado(a). Novo período: 08/10/2025 10:00 a 09/10/2025 10:00.
O serviço do servidor Trevizolo de 12/06/2025 07:00 foi alterado(a). Novo período: 12/06/2025 07:00 a 12/06/2025 17:00.
O serviço do servidor Trevizolo de 12/06/2025 07:00 foi alterado(a). Novo período: 13/06/2025 07:00 a 13/06/2025 17:00.
O serviço do servidor Trevizolo de 13/10/2025 10:00 foi alterado(a). Novo período: 13/10/2025 10:00 a 14/10/2025 10:00.
O serviço do servidor Trevizolo de 14/07/2025 10:00 foi alterado(a). Novo período: 13/07/2025 10:00 a 14/07/2025 10:00.
O serviço do servidor Trevizolo de 16/12/2025 10:00 foi alterado(a). Novo período: 17/12/2025 10:00 a 18/12/2025 10:00.
O serviço do servidor Trevizolo de 17/04/2025 10:00 foi alterado(a). Novo período: 11/04/2025 10:00 a 12/04/2025 10:00.
O serviço do servidor Trevizolo de 23/06/2025 07:00 foi alterado(a). Novo período: 20/06/2025 07:00 a 20/06/2025 17:00.
O serviço do servidor Trevizolo de 26/11/2025 10:00 foi alterado(a). Novo período: 25/11/2025 10:00 a 26/11/2025 10:00.
O serviço do servidor Trevizolo de 29/04/2025 10:00 foi alterado(a). Novo período: 19/04/2025 10:00 a 20/04/2025 10:00.
O serviço do servidor Trevizolo do dia 04/12/2025 foi alterado. Novo período: 10/12/2025 09:00 a 11/12/2025 09:00, na UOP UOP01-DEL03-DF. Permuta com F. Dantas.
O serviço do servidor Trevizolo do dia 12/12/2025 foi alterado. Novo período: 13/12/2025 10:00 a 14/12/2025 10:00. Permuta com Ana Ramos.
O serviço do servidor Trevizolo do dia 14/11/2025 foi alterado. Novo período: 16/11/2025 10:00 a 17/11/2025 10:00. Permuta com B. Simoes.
O serviço do servidor Trevizolo do dia 24/12/2025 foi alterado. Novo período: 25/12/2025 10:00 a 26/12/2025 10:00. Permuta com Diego Veloso.
O serviço do servidor Trevizolo do dia 30/11/2025 foi alterado. Novo período: 29/11/2025 10:00 a 30/11/2025 10:00. Permuta com Mário Seixas.
O serviço do servidor Victor Henrique de 06/08/2025 10:00 foi alterado(a). Novo período: 07/08/2025 10:00 a 08/08/2025 10:00.
O serviço do servidor Victor Henrique de 06/08/2025 10:00 foi alterado(a). Novo período: 08/08/2025 10:00 a 09/08/2025 10:00.
O serviço do servidor Victor Henrique de 07/08/2025 10:00 foi alterado(a). Novo período: 06/08/2025 10:00 a 07/08/2025 10:00.
O serviço do servidor Victor Henrique de 11/09/2025 10:00 foi alterado(a). Novo período: 27/09/2025 10:00 a 28/09/2025 10:00.
O serviço do servidor Victor Henrique de 15/06/2025 10:00 foi alterado(a). Novo período: 16/06/2025 10:00 a 17/06/2025 10:00.
O serviço do servidor Victor Henrique de 16/06/2025 10:00 foi alterado(a). Novo período: 15/06/2025 10:00 a 16/06/2025 10:00.
O serviço do servidor Victor Henrique de 19/06/2025 10:00 foi alterado(a). Novo período: 20/06/2025 10:00 a 21/06/2025 10:00.
O serviço do servidor Victor Henrique de 20/06/2025 10:00 foi alterado(a). Novo período: 19/06/2025 10:00 a 20/06/2025 10:00.
O serviço do servidor Victor Henrique de 20/06/2025 10:00 foi alterado(a). Novo período: 20/06/2025 10:00 a 21/06/2025 10:00.
O serviço do servidor Victor Henrique de 20/06/2025 10:00 foi alterado(a). Novo período: 20/06/2025 10:00 a 21/06/2025 10:00.
O serviço do servidor Victor Henrique de 23/06/2025 10:00 foi alterado(a). Novo período: 24/06/2025 10:00 a 25/06/2025 10:00.
O serviço do servidor Victor Henrique de 24/06/2025 10:00 foi alterado(a). Novo período: 25/06/2025 10:00 a 26/06/2025 10:00.
O serviço do servidor Victor Henrique de 25/06/2025 10:00 foi alterado(a). Novo período: 23/06/2025 10:00 a 24/06/2025 10:00.
O serviço do servidor Victor Henrique de 27/06/2025 10:00 foi alterado(a). Novo período: 28/06/2025 10:00 a 29/06/2025 10:00.
O serviço do servidor Victor Henrique de 28/06/2025 10:00 foi alterado(a). Novo período: 30/06/2025 10:00 a 01/07/2025 10:00.
O serviço do servidor Victor Henrique do dia 16/11/2025 foi alterado. Novo período: 17/11/2025 10:00 a 18/11/2025 10:00. Permuta com Mário Seixas.
O serviço do servidor Victor Henrique do dia 18/12/2025 foi alterado. Novo período: 19/12/2025 10:00 a 20/12/2025 10:00. Permuta com Marcio Araujo.
O serviço do servidor W. Costa de 02/01/2025 10:00 foi alterado(a). Novo período: 01/01/2025 10:00 a 02/01/2025 10:00.
O serviço do servidor W. Costa de 03/03/2025 10:00 foi alterado(a). Novo período: 04/03/2025 10:00 a 05/03/2025 10:00.
O serviço do servidor W. Costa de 03/06/2025 10:00 foi alterado(a). Novo período: 04/06/2025 10:00 a 05/06/2025 10:00.
O serviço do servidor W. Costa de 03/06/2025 10:00 foi alterado(a). Novo período: 23/06/2025 10:00 a 24/06/2025 10:00.
O serviço do servidor W. Costa de 04/06/2025 10:00 foi alterado(a). Novo período: 03/06/2025 10:00 a 04/06/2025 10:00.
O serviço do servidor W. Costa de 07/03/2025 10:00 foi alterado(a). Novo período: 08/03/2025 10:00 a 09/03/2025 10:00.
O serviço do servidor W. Costa de 07/06/2025 10:00 foi alterado(a). Novo período: 08/06/2025 10:00 a 09/06/2025 10:00.
O serviço do servidor W. Costa de 08/06/2025 10:00 foi alterado(a). Novo período: 07/06/2025 10:00 a 08/06/2025 10:00.
O serviço do servidor W. Costa de 11/03/2025 10:00 foi alterado(a). Novo período: 12/03/2025 10:00 a 13/03/2025 10:00.
O serviço do servidor W. Costa de 11/06/2025 10:00 foi alterado(a). Novo período: 12/06/2025 10:00 a 13/06/2025 10:00.
O serviço do servidor W. Costa de 12/06/2025 10:00 foi alterado(a). Novo período: 11/06/2025 10:00 a 12/06/2025 10:00.
O serviço do servidor W. Costa de 15/03/2025 10:00 foi alterado(a). Novo período: 16/03/2025 10:00 a 17/03/2025 10:00.
O serviço do servidor W. Costa de 15/06/2025 10:00 foi alterado(a). Novo período: 16/06/2025 10:00 a 17/06/2025 10:00.
O serviço do servidor W. Costa de 16/06/2025 10:00 foi alterado(a). Novo período: 15/06/2025 10:00 a 16/06/2025 10:00.
O serviço do servidor W. Costa de 19/03/2025 10:00 foi alterado(a). Novo período: 20/03/2025 10:00 a 21/03/2025 10:00.
O serviço do servidor W. Costa de 19/06/2025 10:00 foi alterado(a). Novo período: 19/06/2025 10:00 a 20/06/2025 10:00.
O serviço do servidor W. Costa de 23/03/2025 10:00 foi alterado(a). Novo período: 24/03/2025 10:00 a 25/03/2025 10:00.
O serviço do servidor W. Costa do dia 08/03/2025 foi alterado. Novo período: 07/03/2025 10:00 a 08/03/2025 10:00. Permuta com C. Neri.
O serviço do servidor W. Costa do dia 16/04/2025 foi alterado. Novo período: 15/04/2025 10:00 a 16/04/2025 10:00. Permuta com Costa Gomes.
O serviço do servidor Zardo de 17/08/2025 09:00 foi alterado(a). Novo período: 21/08/2025 09:00 a 22/08/2025 09:00.
O serviço do servidor Zardo do dia 13/11/2025 foi alterado. Novo período: 12/11/2025 09:00 a 13/11/2025 09:00. Permuta com Estelles.
O serviço do servidor Zardo do dia 17/11/2025 foi alterado. Novo período: 18/11/2025 09:00 a 19/11/2025 09:00. Permuta com Osmar Cardoso.
O serviço do servidor Zardo do dia 27/12/2025 foi alterado. Novo período: 28/12/2025 09:00 a 29/12/2025 09:00. Permuta com M. Nogueira.
O serviço do servidor Zardo do dia 28/12/2025 foi alterado. Novo período: 26/12/2025 09:00 a 27/12/2025 09:00. Permuta com Jonas Felipe.
O serviço do servidor Zardo do dia 30/07/2025 foi alterado. Novo período: 02/07/2025 09:00 a 03/07/2025 09:00, na UOP UOP01-DEL03-DF. Permuta com Augustus Cutrim.
```    
    [[/knowledge_first_set_ptbr]]
    </knowledge_first_set_ptbr>
    <knowledge_second_set_json_ptbr>
    [[knowledge_second_set_json_ptbr]]
```knowledge_second_set_json_ptbr
{
  "data": [
    {
      "Nome": "Joao Batista de Oliveira",
      "Matrícula": "0160598",
      "Lotação": "DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-05-12",
      "Fim": "2025-06-10"
    },
    {
      "Nome": "Marcelo Berto da Silva",
      "Matrícula": "1094617",
      "Lotação": "DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-07-21",
      "Fim": "2025-07-30"
    },
    {
      "Nome": "Marcelo Berto da Silva",
      "Matrícula": "1094617",
      "Lotação": "DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-12-31",
      "Fim": "2025-12-31"
    },
    {
      "Nome": "Marcelo Berto da Silva",
      "Matrícula": "1094617",
      "Lotação": "DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2026-01-01",
      "Fim": "2026-01-05"
    },
    {
      "Nome": "Marcelo Berto da Silva",
      "Matrícula": "1094617",
      "Lotação": "DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2026-01-06",
      "Fim": "2026-01-10"
    },
    {
      "Nome": "Pedro Henrique de Castro Fiquene (Fiquene)",
      "Matrícula": "2327931",
      "Lotação": "DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-03-26",
      "Fim": "2025-04-04"
    },
    {
      "Nome": "Adauto Campos Moreira (Adauto Moreira)",
      "Matrícula": "1395219",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-10-03",
      "Fim": "2025-10-05"
    },
    {
      "Nome": "Adauto Campos Moreira (Adauto Moreira)",
      "Matrícula": "1395219",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-10-06",
      "Fim": "2025-10-10"
    },
    {
      "Nome": "Adauto Campos Moreira (Adauto Moreira)",
      "Matrícula": "1395219",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência ?",
      "Início": "2025-10-12",
      "Fim": "2025-11-30"
    },
    {
      "Nome": "Adauto Campos Moreira (Adauto Moreira)",
      "Matrícula": "1395219",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-11-25",
      "Fim": "2025-11-25"
    },
    {
      "Nome": "Adauto Campos Moreira (Adauto Moreira)",
      "Matrícula": "1395219",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-12-19",
      "Fim": "2025-12-22"
    },
    {
      "Nome": "Adauto Campos Moreira (Adauto Moreira)",
      "Matrícula": "1395219",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-12-23",
      "Fim": "2026-01-07"
    },
    {
      "Nome": "Alessandro Vieira de Castro (A. Castro)",
      "Matrícula": "1478473",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-01-03",
      "Fim": "2025-01-12"
    },
    {
      "Nome": "Alessandro Vieira de Castro (A. Castro)",
      "Matrícula": "1478473",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência",
      "Início": "2025-01-15",
      "Fim": "2025-01-16"
    },
    {
      "Nome": "Alessandro Vieira de Castro (A. Castro)",
      "Matrícula": "1478473",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência",
      "Início": "2025-01-19",
      "Fim": "2025-01-20"
    },
    {
      "Nome": "Alessandro Vieira de Castro (A. Castro)",
      "Matrícula": "1478473",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-02-11",
      "Fim": "2025-02-14"
    },
    {
      "Nome": "Alessandro Vieira de Castro (A. Castro)",
      "Matrícula": "1478473",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-02-16",
      "Fim": "2025-02-16"
    },
    {
      "Nome": "Alessandro Vieira de Castro (A. Castro)",
      "Matrícula": "1478473",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-03-29",
      "Fim": "2025-03-29"
    },
    {
      "Nome": "Alessandro Vieira de Castro (A. Castro)",
      "Matrícula": "1478473",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-04-12",
      "Fim": "2025-04-12"
    },
    {
      "Nome": "Alessandro Vieira de Castro (A. Castro)",
      "Matrícula": "1478473",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-04-24",
      "Fim": "2025-04-29"
    },
    {
      "Nome": "Alessandro Vieira de Castro (A. Castro)",
      "Matrícula": "1478473",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-15",
      "Fim": "2025-05-15"
    },
    {
      "Nome": "Alessandro Vieira de Castro (A. Castro)",
      "Matrícula": "1478473",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-08",
      "Fim": "2025-06-08"
    },
    {
      "Nome": "Alessandro Vieira de Castro (A. Castro)",
      "Matrícula": "1478473",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-06-16",
      "Fim": "2025-06-17"
    },
    {
      "Nome": "Alessandro Vieira de Castro (A. Castro)",
      "Matrícula": "1478473",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-07-14",
      "Fim": "2025-07-23"
    },
    {
      "Nome": "Alessandro Vieira de Castro (A. Castro)",
      "Matrícula": "1478473",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-08",
      "Fim": "2025-08-08"
    },
    {
      "Nome": "Alessandro Vieira de Castro (A. Castro)",
      "Matrícula": "1478473",
      "Lotação": "NPF/DEL03-DF",
      "Código": "90",
      "Sigla": "LICMDPEFAM",
      "Descrição": "Lic. por Motivo de Doença em Pesssoa da Família - EST NÃO Permite Frequência",
      "Início": "2025-08-20",
      "Fim": "2025-08-23"
    },
    {
      "Nome": "Alessandro Vieira de Castro (A. Castro)",
      "Matrícula": "1478473",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-09-27",
      "Fim": "2025-09-27"
    },
    {
      "Nome": "Alessandro Vieira de Castro (A. Castro)",
      "Matrícula": "1478473",
      "Lotação": "NPF/DEL03-DF",
      "Código": "81",
      "Sigla": "LICCPACITA",
      "Descrição": "Lic. Capacitação - EST NÃO Permite Frequência ?",
      "Início": "2025-10-01",
      "Fim": "2025-12-29"
    },
    {
      "Nome": "Ana Claudia Ramos (Ana Ramos)",
      "Matrícula": "3263481",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-07-02",
      "Fim": "2025-07-04"
    },
    {
      "Nome": "Ana Claudia Ramos (Ana Ramos)",
      "Matrícula": "3263481",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência",
      "Início": "2025-07-05",
      "Fim": "2025-07-08"
    },
    {
      "Nome": "Ana Claudia Ramos (Ana Ramos)",
      "Matrícula": "3263481",
      "Lotação": "NPF/DEL03-DF",
      "Código": "32",
      "Sigla": "AFTRPPTPOL",
      "Descrição": "Afas. Est/Prog.Trein.(Congr-Encon) País C/Ônus Limit - EST NÃO Permite Frequência",
      "Início": "2025-08-25",
      "Fim": "2025-10-08"
    },
    {
      "Nome": "Ana Claudia Ramos (Ana Ramos)",
      "Matrícula": "3263481",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-22",
      "Fim": "2025-10-22"
    },
    {
      "Nome": "Ana Claudia Ramos (Ana Ramos)",
      "Matrícula": "3263481",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-11-19",
      "Fim": "2025-11-19"
    },
    {
      "Nome": "Ana Claudia Ramos (Ana Ramos)",
      "Matrícula": "3263481",
      "Lotação": "NPF/DEL03-DF",
      "Código": "90",
      "Sigla": "LICMDPEFAM",
      "Descrição": "Lic. por Motivo de Doença em Pesssoa da Família - EST NÃO Permite Frequência",
      "Início": "2025-11-24",
      "Fim": "2025-12-03"
    },
    {
      "Nome": "Ana Claudia Ramos (Ana Ramos)",
      "Matrícula": "3263481",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência",
      "Início": "2025-12-20",
      "Fim": "2026-01-14"
    },
    {
      "Nome": "Ananias Jose Pereira (Pereira II)",
      "Matrícula": "1302941",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência",
      "Início": "2025-01-02",
      "Fim": "2025-01-17"
    },
    {
      "Nome": "Ananias Jose Pereira (Pereira II)",
      "Matrícula": "1302941",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-01-31",
      "Fim": "2025-01-31"
    },
    {
      "Nome": "Ananias Jose Pereira (Pereira II)",
      "Matrícula": "1302941",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-03-21",
      "Fim": "2025-03-21"
    },
    {
      "Nome": "Ananias Jose Pereira (Pereira II)",
      "Matrícula": "1302941",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-04-02",
      "Fim": "2025-04-02"
    },
    {
      "Nome": "Ananias Jose Pereira (Pereira II)",
      "Matrícula": "1302941",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência ?",
      "Início": "2025-04-12",
      "Fim": "2025-05-02"
    },
    {
      "Nome": "Ananias Jose Pereira (Pereira II)",
      "Matrícula": "1302941",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-20",
      "Fim": "2025-05-20"
    },
    {
      "Nome": "Ananias Jose Pereira (Pereira II)",
      "Matrícula": "1302941",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-28",
      "Fim": "2025-05-28"
    },
    {
      "Nome": "Ananias Jose Pereira (Pereira II)",
      "Matrícula": "1302941",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-01",
      "Fim": "2025-06-01"
    },
    {
      "Nome": "Ananias Jose Pereira (Pereira II)",
      "Matrícula": "1302941",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência ?",
      "Início": "2025-06-15",
      "Fim": "2025-07-01"
    },
    {
      "Nome": "Ananias Jose Pereira (Pereira II)",
      "Matrícula": "1302941",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-07-19",
      "Fim": "2025-07-19"
    },
    {
      "Nome": "Ananias Jose Pereira (Pereira II)",
      "Matrícula": "1302941",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-08",
      "Fim": "2025-08-08"
    },
    {
      "Nome": "Ananias Jose Pereira (Pereira II)",
      "Matrícula": "1302941",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-08-20",
      "Fim": "2025-08-29"
    },
    {
      "Nome": "Ananias Jose Pereira (Pereira II)",
      "Matrícula": "1302941",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-09-01",
      "Fim": "2025-09-19"
    },
    {
      "Nome": "Ananias Jose Pereira (Pereira II)",
      "Matrícula": "1302941",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-09-23",
      "Fim": "2025-09-23"
    },
    {
      "Nome": "Ananias Jose Pereira (Pereira II)",
      "Matrícula": "1302941",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-09-28",
      "Fim": "2025-09-28"
    },
    {
      "Nome": "Ananias Jose Pereira (Pereira II)",
      "Matrícula": "1302941",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-01",
      "Fim": "2025-10-01"
    },
    {
      "Nome": "Ananias Jose Pereira (Pereira II)",
      "Matrícula": "1302941",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência ?",
      "Início": "2025-10-20",
      "Fim": "2025-10-21"
    },
    {
      "Nome": "Ananias Jose Pereira (Pereira II)",
      "Matrícula": "1302941",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência ?",
      "Início": "2025-11-05",
      "Fim": "2026-01-14"
    },
    {
      "Nome": "Andre Araujo Barbosa (Andre Araujo)",
      "Matrícula": "2151359",
      "Lotação": "NPF/DEL03-DF",
      "Código": "81",
      "Sigla": "LICCPACITA",
      "Descrição": "Lic. Capacitação - EST NÃO Permite Frequência",
      "Início": "2025-01-02",
      "Fim": "2025-04-01"
    },
    {
      "Nome": "Andre Araujo Barbosa (Andre Araujo)",
      "Matrícula": "2151359",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-04-23",
      "Fim": "2025-04-23"
    },
    {
      "Nome": "Andre Araujo Barbosa (Andre Araujo)",
      "Matrícula": "2151359",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-09",
      "Fim": "2025-05-09"
    },
    {
      "Nome": "Andre Araujo Barbosa (Andre Araujo)",
      "Matrícula": "2151359",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-05-16",
      "Fim": "2025-05-18"
    },
    {
      "Nome": "Andre Araujo Barbosa (Andre Araujo)",
      "Matrícula": "2151359",
      "Lotação": "NPF/DEL03-DF",
      "Código": "90",
      "Sigla": "LICMDPEFAM",
      "Descrição": "Lic. por Motivo de Doença em Pesssoa da Família - EST NÃO Permite Frequência",
      "Início": "2025-07-11",
      "Fim": "2025-07-17"
    },
    {
      "Nome": "Andre Araujo Barbosa (Andre Araujo)",
      "Matrícula": "2151359",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-08-04",
      "Fim": "2025-08-13"
    },
    {
      "Nome": "Andre Araujo Barbosa (Andre Araujo)",
      "Matrícula": "2151359",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-08-19",
      "Fim": "2025-08-29"
    },
    {
      "Nome": "Andre Araujo Barbosa (Andre Araujo)",
      "Matrícula": "2151359",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-09-10",
      "Fim": "2025-09-10"
    },
    {
      "Nome": "Andre Araujo Barbosa (Andre Araujo)",
      "Matrícula": "2151359",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-10-19",
      "Fim": "2025-10-23"
    },
    {
      "Nome": "Andre Araujo Barbosa (Andre Araujo)",
      "Matrícula": "2151359",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-10-24",
      "Fim": "2025-11-02"
    },
    {
      "Nome": "Andre Araujo Barbosa (Andre Araujo)",
      "Matrícula": "2151359",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-11-21",
      "Fim": "2025-11-21"
    },
    {
      "Nome": "Andre Araujo Barbosa (Andre Araujo)",
      "Matrícula": "2151359",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-12-02",
      "Fim": "2025-12-04"
    },
    {
      "Nome": "Andre Araujo Barbosa (Andre Araujo)",
      "Matrícula": "2151359",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-12-22",
      "Fim": "2025-12-31"
    },
    {
      "Nome": "Andreloiso Nunes de Lima Torres (Torres)",
      "Matrícula": "1301448",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-01-08",
      "Fim": "2025-01-22"
    },
    {
      "Nome": "Andreloiso Nunes de Lima Torres (Torres)",
      "Matrícula": "1301448",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-02-23",
      "Fim": "2025-02-23"
    },
    {
      "Nome": "Andreloiso Nunes de Lima Torres (Torres)",
      "Matrícula": "1301448",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-03-11",
      "Fim": "2025-03-11"
    },
    {
      "Nome": "Andreloiso Nunes de Lima Torres (Torres)",
      "Matrícula": "1301448",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-03-15",
      "Fim": "2025-03-15"
    },
    {
      "Nome": "Andreloiso Nunes de Lima Torres (Torres)",
      "Matrícula": "1301448",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-04-08",
      "Fim": "2025-04-08"
    },
    {
      "Nome": "Andreloiso Nunes de Lima Torres (Torres)",
      "Matrícula": "1301448",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-04-14",
      "Fim": "2025-04-14"
    },
    {
      "Nome": "Andreloiso Nunes de Lima Torres (Torres)",
      "Matrícula": "1301448",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência ?",
      "Início": "2025-04-21",
      "Fim": "2025-06-01"
    },
    {
      "Nome": "Andreloiso Nunes de Lima Torres (Torres)",
      "Matrícula": "1301448",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-17",
      "Fim": "2025-06-17"
    },
    {
      "Nome": "Andreloiso Nunes de Lima Torres (Torres)",
      "Matrícula": "1301448",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-19",
      "Fim": "2025-06-19"
    },
    {
      "Nome": "Andreloiso Nunes de Lima Torres (Torres)",
      "Matrícula": "1301448",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência ?",
      "Início": "2025-06-21",
      "Fim": "2025-07-11"
    },
    {
      "Nome": "Andreloiso Nunes de Lima Torres (Torres)",
      "Matrícula": "1301448",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-05",
      "Fim": "2025-08-05"
    },
    {
      "Nome": "Andreloiso Nunes de Lima Torres (Torres)",
      "Matrícula": "1301448",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-11",
      "Fim": "2025-08-11"
    },
    {
      "Nome": "Andreloiso Nunes de Lima Torres (Torres)",
      "Matrícula": "1301448",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-21",
      "Fim": "2025-08-21"
    },
    {
      "Nome": "Andreloiso Nunes de Lima Torres (Torres)",
      "Matrícula": "1301448",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência ?",
      "Início": "2025-08-25",
      "Fim": "2025-10-08"
    },
    {
      "Nome": "Andreloiso Nunes de Lima Torres (Torres)",
      "Matrícula": "1301448",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-09",
      "Fim": "2025-10-09"
    },
    {
      "Nome": "Andreloiso Nunes de Lima Torres (Torres)",
      "Matrícula": "1301448",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-15",
      "Fim": "2025-10-15"
    },
    {
      "Nome": "Andreloiso Nunes de Lima Torres (Torres)",
      "Matrícula": "1301448",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência ?",
      "Início": "2025-10-19",
      "Fim": "2025-11-12"
    },
    {
      "Nome": "Andreloiso Nunes de Lima Torres (Torres)",
      "Matrícula": "1301448",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-12-17",
      "Fim": "2025-12-31"
    },
    {
      "Nome": "Andreloiso Nunes de Lima Torres (Torres)",
      "Matrícula": "1301448",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência",
      "Início": "2026-01-02",
      "Fim": "2026-01-02"
    },
    {
      "Nome": "Augustus Cunha Cutrim Penha (Augustus Cutrim)",
      "Matrícula": "1880129",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2024-12-15",
      "Fim": "2025-01-06"
    },
    {
      "Nome": "Augustus Cunha Cutrim Penha (Augustus Cutrim)",
      "Matrícula": "1880129",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência",
      "Início": "2025-01-16",
      "Fim": "2025-01-17"
    },
    {
      "Nome": "Augustus Cunha Cutrim Penha (Augustus Cutrim)",
      "Matrícula": "1880129",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-01-25",
      "Fim": "2025-01-25"
    },
    {
      "Nome": "Augustus Cunha Cutrim Penha (Augustus Cutrim)",
      "Matrícula": "1880129",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-01-29",
      "Fim": "2025-01-30"
    },
    {
      "Nome": "Augustus Cunha Cutrim Penha (Augustus Cutrim)",
      "Matrícula": "1880129",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-02-02",
      "Fim": "2025-02-02"
    },
    {
      "Nome": "Augustus Cunha Cutrim Penha (Augustus Cutrim)",
      "Matrícula": "1880129",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência",
      "Início": "2025-03-10",
      "Fim": "2025-03-26"
    },
    {
      "Nome": "Augustus Cunha Cutrim Penha (Augustus Cutrim)",
      "Matrícula": "1880129",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-03-30",
      "Fim": "2025-03-30"
    },
    {
      "Nome": "Augustus Cunha Cutrim Penha (Augustus Cutrim)",
      "Matrícula": "1880129",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-05",
      "Fim": "2025-05-05"
    },
    {
      "Nome": "Augustus Cunha Cutrim Penha (Augustus Cutrim)",
      "Matrícula": "1880129",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-25",
      "Fim": "2025-05-25"
    },
    {
      "Nome": "Augustus Cunha Cutrim Penha (Augustus Cutrim)",
      "Matrícula": "1880129",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-10",
      "Fim": "2025-06-10"
    },
    {
      "Nome": "Augustus Cunha Cutrim Penha (Augustus Cutrim)",
      "Matrícula": "1880129",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-22",
      "Fim": "2025-06-22"
    },
    {
      "Nome": "Augustus Cunha Cutrim Penha (Augustus Cutrim)",
      "Matrícula": "1880129",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-30",
      "Fim": "2025-06-30"
    },
    {
      "Nome": "Augustus Cunha Cutrim Penha (Augustus Cutrim)",
      "Matrícula": "1880129",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-07-13",
      "Fim": "2025-07-20"
    },
    {
      "Nome": "Augustus Cunha Cutrim Penha (Augustus Cutrim)",
      "Matrícula": "1880129",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-07-24",
      "Fim": "2025-07-24"
    },
    {
      "Nome": "Augustus Cunha Cutrim Penha (Augustus Cutrim)",
      "Matrícula": "1880129",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-07-28",
      "Fim": "2025-07-28"
    },
    {
      "Nome": "Augustus Cunha Cutrim Penha (Augustus Cutrim)",
      "Matrícula": "1880129",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-01",
      "Fim": "2025-08-01"
    },
    {
      "Nome": "Augustus Cunha Cutrim Penha (Augustus Cutrim)",
      "Matrícula": "1880129",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-13",
      "Fim": "2025-08-13"
    },
    {
      "Nome": "Augustus Cunha Cutrim Penha (Augustus Cutrim)",
      "Matrícula": "1880129",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-09-06",
      "Fim": "2025-09-06"
    },
    {
      "Nome": "Augustus Cunha Cutrim Penha (Augustus Cutrim)",
      "Matrícula": "1880129",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-09-18",
      "Fim": "2025-09-30"
    },
    {
      "Nome": "Augustus Cunha Cutrim Penha (Augustus Cutrim)",
      "Matrícula": "1880129",
      "Lotação": "NPF/DEL03-DF",
      "Código": "81",
      "Sigla": "LICCPACITA",
      "Descrição": "Lic. Capacitação - EST NÃO Permite Frequência ?",
      "Início": "2025-10-01",
      "Fim": "2025-12-29"
    },
    {
      "Nome": "Augustus Cunha Cutrim Penha (Augustus Cutrim)",
      "Matrícula": "1880129",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-12-31",
      "Fim": "2026-01-08"
    },
    {
      "Nome": "Bruno Monteiro Simoes (B. Simoes)",
      "Matrícula": "2334979",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-01-08",
      "Fim": "2025-02-06"
    },
    {
      "Nome": "Bruno Monteiro Simoes (B. Simoes)",
      "Matrícula": "2334979",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-02-08",
      "Fim": "2025-03-09"
    },
    {
      "Nome": "Bruno Monteiro Simoes (B. Simoes)",
      "Matrícula": "2334979",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-03-07",
      "Fim": "2025-03-26"
    },
    {
      "Nome": "Bruno Monteiro Simoes (B. Simoes)",
      "Matrícula": "2334979",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência ?",
      "Início": "2025-03-27",
      "Fim": "2025-04-25"
    },
    {
      "Nome": "Bruno Monteiro Simoes (B. Simoes)",
      "Matrícula": "2334979",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência ?",
      "Início": "2025-03-27",
      "Fim": "2025-03-30"
    },
    {
      "Nome": "Bruno Monteiro Simoes (B. Simoes)",
      "Matrícula": "2334979",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência ?",
      "Início": "2025-08-24",
      "Fim": "2025-08-30"
    },
    {
      "Nome": "Bruno Monteiro Simoes (B. Simoes)",
      "Matrícula": "2334979",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-31",
      "Fim": "2025-08-31"
    },
    {
      "Nome": "Bruno Monteiro Simoes (B. Simoes)",
      "Matrícula": "2334979",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-09-13",
      "Fim": "2025-09-13"
    },
    {
      "Nome": "Bruno Monteiro Simoes (B. Simoes)",
      "Matrícula": "2334979",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-02",
      "Fim": "2025-10-02"
    },
    {
      "Nome": "Bruno Monteiro Simoes (B. Simoes)",
      "Matrícula": "2334979",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência",
      "Início": "2025-10-06",
      "Fim": "2025-10-10"
    },
    {
      "Nome": "Bruno Monteiro Simoes (B. Simoes)",
      "Matrícula": "2334979",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência ?",
      "Início": "2025-10-16",
      "Fim": "2025-10-20"
    },
    {
      "Nome": "Bruno Monteiro Simoes (B. Simoes)",
      "Matrícula": "2334979",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-11-19",
      "Fim": "2025-11-20"
    },
    {
      "Nome": "Bruno Monteiro Simoes (B. Simoes)",
      "Matrícula": "2334979",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-12-05",
      "Fim": "2025-12-06"
    },
    {
      "Nome": "Bruno Monteiro Simoes (B. Simoes)",
      "Matrícula": "2334979",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-12-11",
      "Fim": "2025-12-20"
    },
    {
      "Nome": "Bruno Monteiro Simoes (B. Simoes)",
      "Matrícula": "2334979",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2026-01-05",
      "Fim": "2026-01-23"
    },
    {
      "Nome": "Carlos Augusto Dias Ribeiro (Augusto Ribeiro)",
      "Matrícula": "1990476",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-01-05",
      "Fim": "2025-01-19"
    },
    {
      "Nome": "Carlos Augusto Dias Ribeiro (Augusto Ribeiro)",
      "Matrícula": "1990476",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-20",
      "Fim": "2025-05-20"
    },
    {
      "Nome": "Carlos Augusto Dias Ribeiro (Augusto Ribeiro)",
      "Matrícula": "1990476",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-24",
      "Fim": "2025-05-24"
    },
    {
      "Nome": "Carlos Augusto Dias Ribeiro (Augusto Ribeiro)",
      "Matrícula": "1990476",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-28",
      "Fim": "2025-05-28"
    },
    {
      "Nome": "Carlos Augusto Dias Ribeiro (Augusto Ribeiro)",
      "Matrícula": "1990476",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-09",
      "Fim": "2025-06-09"
    },
    {
      "Nome": "Carlos Augusto Dias Ribeiro (Augusto Ribeiro)",
      "Matrícula": "1990476",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-17",
      "Fim": "2025-06-17"
    },
    {
      "Nome": "Carlos Augusto Dias Ribeiro (Augusto Ribeiro)",
      "Matrícula": "1990476",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-06-21",
      "Fim": "2025-06-21"
    },
    {
      "Nome": "Carlos Augusto Dias Ribeiro (Augusto Ribeiro)",
      "Matrícula": "1990476",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-07-07",
      "Fim": "2025-07-07"
    },
    {
      "Nome": "Carlos Augusto Dias Ribeiro (Augusto Ribeiro)",
      "Matrícula": "1990476",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-07-15",
      "Fim": "2025-07-15"
    },
    {
      "Nome": "Carlos Augusto Dias Ribeiro (Augusto Ribeiro)",
      "Matrícula": "1990476",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-07-23",
      "Fim": "2025-07-23"
    },
    {
      "Nome": "Carlos Augusto Dias Ribeiro (Augusto Ribeiro)",
      "Matrícula": "1990476",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-08",
      "Fim": "2025-08-08"
    },
    {
      "Nome": "Carlos Augusto Dias Ribeiro (Augusto Ribeiro)",
      "Matrícula": "1990476",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-12",
      "Fim": "2025-08-12"
    },
    {
      "Nome": "Carlos Augusto Dias Ribeiro (Augusto Ribeiro)",
      "Matrícula": "1990476",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-20",
      "Fim": "2025-08-20"
    },
    {
      "Nome": "Carlos Augusto Dias Ribeiro (Augusto Ribeiro)",
      "Matrícula": "1990476",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-09-01",
      "Fim": "2025-09-01"
    },
    {
      "Nome": "Carlos Augusto Dias Ribeiro (Augusto Ribeiro)",
      "Matrícula": "1990476",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-09-17",
      "Fim": "2025-09-30"
    },
    {
      "Nome": "Carlos Augusto Dias Ribeiro (Augusto Ribeiro)",
      "Matrícula": "1990476",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-03",
      "Fim": "2025-10-03"
    },
    {
      "Nome": "Carlos Augusto Dias Ribeiro (Augusto Ribeiro)",
      "Matrícula": "1990476",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-07",
      "Fim": "2025-10-07"
    },
    {
      "Nome": "Carlos Augusto Dias Ribeiro (Augusto Ribeiro)",
      "Matrícula": "1990476",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-31",
      "Fim": "2025-10-31"
    },
    {
      "Nome": "Carlos Augusto Dias Ribeiro (Augusto Ribeiro)",
      "Matrícula": "1990476",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-12-18",
      "Fim": "2025-12-18"
    },
    {
      "Nome": "Carlos Roberto de Oliveira (Roberto)",
      "Matrícula": "1554682",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-01-30",
      "Fim": "2025-02-28"
    },
    {
      "Nome": "Carlos Roberto de Oliveira (Roberto)",
      "Matrícula": "1554682",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-03-05",
      "Fim": "2025-03-05"
    },
    {
      "Nome": "Carlos Roberto de Oliveira (Roberto)",
      "Matrícula": "1554682",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-03-09",
      "Fim": "2025-03-09"
    },
    {
      "Nome": "Carlos Roberto de Oliveira (Roberto)",
      "Matrícula": "1554682",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-03-13",
      "Fim": "2025-03-13"
    },
    {
      "Nome": "Carlos Roberto de Oliveira (Roberto)",
      "Matrícula": "1554682",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-04-08",
      "Fim": "2025-04-08"
    },
    {
      "Nome": "Carlos Roberto de Oliveira (Roberto)",
      "Matrícula": "1554682",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência ?",
      "Início": "2025-04-12",
      "Fim": "2025-05-02"
    },
    {
      "Nome": "Carlos Roberto de Oliveira (Roberto)",
      "Matrícula": "1554682",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-06",
      "Fim": "2025-05-06"
    },
    {
      "Nome": "Carlos Roberto de Oliveira (Roberto)",
      "Matrícula": "1554682",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-07",
      "Fim": "2025-05-07"
    },
    {
      "Nome": "Carlos Roberto de Oliveira (Roberto)",
      "Matrícula": "1554682",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-09",
      "Fim": "2025-05-09"
    },
    {
      "Nome": "Carlos Roberto de Oliveira (Roberto)",
      "Matrícula": "1554682",
      "Lotação": "NPF/DEL03-DF",
      "Código": "32",
      "Sigla": "AFTRPPTPOL",
      "Descrição": "Afas. Est/Prog.Trein.(Congr-Encon) País C/Ônus Limit - EST NÃO Permite Frequência ?",
      "Início": "2025-05-13",
      "Fim": "2025-05-13"
    },
    {
      "Nome": "Carlos Roberto de Oliveira (Roberto)",
      "Matrícula": "1554682",
      "Lotação": "NPF/DEL03-DF",
      "Código": "32",
      "Sigla": "AFTRPPTPOL",
      "Descrição": "Afas. Est/Prog.Trein.(Congr-Encon) País C/Ônus Limit - EST NÃO Permite Frequência ?",
      "Início": "2025-05-19",
      "Fim": "2025-05-19"
    },
    {
      "Nome": "Carlos Roberto de Oliveira (Roberto)",
      "Matrícula": "1554682",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-21",
      "Fim": "2025-05-21"
    },
    {
      "Nome": "Carlos Roberto de Oliveira (Roberto)",
      "Matrícula": "1554682",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-23",
      "Fim": "2025-05-23"
    },
    {
      "Nome": "Carlos Roberto de Oliveira (Roberto)",
      "Matrícula": "1554682",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-11",
      "Fim": "2025-06-11"
    },
    {
      "Nome": "Carlos Roberto de Oliveira (Roberto)",
      "Matrícula": "1554682",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência ?",
      "Início": "2025-06-21",
      "Fim": "2025-07-11"
    },
    {
      "Nome": "Carlos Roberto de Oliveira (Roberto)",
      "Matrícula": "1554682",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-11",
      "Fim": "2025-08-11"
    },
    {
      "Nome": "Carlos Roberto de Oliveira (Roberto)",
      "Matrícula": "1554682",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência",
      "Início": "2025-08-15",
      "Fim": "2025-08-15"
    },
    {
      "Nome": "Carlos Roberto de Oliveira (Roberto)",
      "Matrícula": "1554682",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-08-29",
      "Fim": "2025-08-29"
    },
    {
      "Nome": "Carlos Roberto de Oliveira (Roberto)",
      "Matrícula": "1554682",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência",
      "Início": "2025-09-10",
      "Fim": "2025-09-18"
    },
    {
      "Nome": "Carlos Roberto de Oliveira (Roberto)",
      "Matrícula": "1554682",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-01",
      "Fim": "2025-10-01"
    },
    {
      "Nome": "Carlos Roberto de Oliveira (Roberto)",
      "Matrícula": "1554682",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-07",
      "Fim": "2025-10-07"
    },
    {
      "Nome": "Carlos Roberto de Oliveira (Roberto)",
      "Matrícula": "1554682",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-09",
      "Fim": "2025-10-09"
    },
    {
      "Nome": "Carlos Roberto de Oliveira (Roberto)",
      "Matrícula": "1554682",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-13",
      "Fim": "2025-10-13"
    },
    {
      "Nome": "Carlos Roberto de Oliveira (Roberto)",
      "Matrícula": "1554682",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-15",
      "Fim": "2025-10-15"
    },
    {
      "Nome": "Carlos Roberto de Oliveira (Roberto)",
      "Matrícula": "1554682",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-17",
      "Fim": "2025-10-17"
    },
    {
      "Nome": "Carlos Roberto de Oliveira (Roberto)",
      "Matrícula": "1554682",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência ?",
      "Início": "2025-10-19",
      "Fim": "2025-11-12"
    },
    {
      "Nome": "Carlos Roberto de Oliveira (Roberto)",
      "Matrícula": "1554682",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-11-14",
      "Fim": "2025-11-14"
    },
    {
      "Nome": "Carlos Roberto de Oliveira (Roberto)",
      "Matrícula": "1554682",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-11-28",
      "Fim": "2025-11-28"
    },
    {
      "Nome": "Carlos Roberto de Oliveira (Roberto)",
      "Matrícula": "1554682",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência",
      "Início": "2025-12-24",
      "Fim": "2025-12-24"
    },
    {
      "Nome": "Carlos Roberto de Oliveira (Roberto)",
      "Matrícula": "1554682",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2026-01-02",
      "Fim": "2026-01-31"
    },
    {
      "Nome": "Cecilia Silva Cavadas (Cavadas)",
      "Matrícula": "1256137",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-01-08",
      "Fim": "2025-01-17"
    },
    {
      "Nome": "Cecilia Silva Cavadas (Cavadas)",
      "Matrícula": "1256137",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-03-20",
      "Fim": "2025-03-20"
    },
    {
      "Nome": "Cecilia Silva Cavadas (Cavadas)",
      "Matrícula": "1256137",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-04-13",
      "Fim": "2025-04-22"
    },
    {
      "Nome": "Cecilia Silva Cavadas (Cavadas)",
      "Matrícula": "1256137",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-27",
      "Fim": "2025-05-27"
    },
    {
      "Nome": "Cecilia Silva Cavadas (Cavadas)",
      "Matrícula": "1256137",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-31",
      "Fim": "2025-05-31"
    },
    {
      "Nome": "Cecilia Silva Cavadas (Cavadas)",
      "Matrícula": "1256137",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência ?",
      "Início": "2025-06-15",
      "Fim": "2025-07-01"
    },
    {
      "Nome": "Cecilia Silva Cavadas (Cavadas)",
      "Matrícula": "1256137",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-07-02",
      "Fim": "2025-07-02"
    },
    {
      "Nome": "Cecilia Silva Cavadas (Cavadas)",
      "Matrícula": "1256137",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-07-22",
      "Fim": "2025-07-31"
    },
    {
      "Nome": "Cecilia Silva Cavadas (Cavadas)",
      "Matrícula": "1256137",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-03",
      "Fim": "2025-08-03"
    },
    {
      "Nome": "Cecilia Silva Cavadas (Cavadas)",
      "Matrícula": "1256137",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-09-20",
      "Fim": "2025-09-20"
    },
    {
      "Nome": "Cecilia Silva Cavadas (Cavadas)",
      "Matrícula": "1256137",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-09-24",
      "Fim": "2025-10-03"
    },
    {
      "Nome": "Cecilia Silva Cavadas (Cavadas)",
      "Matrícula": "1256137",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-18",
      "Fim": "2025-10-18"
    },
    {
      "Nome": "Cecilia Silva Cavadas (Cavadas)",
      "Matrícula": "1256137",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-11-11",
      "Fim": "2025-11-11"
    },
    {
      "Nome": "Cecilia Silva Cavadas (Cavadas)",
      "Matrícula": "1256137",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-12-11",
      "Fim": "2025-12-13"
    },
    {
      "Nome": "Cecilia Silva Cavadas (Cavadas)",
      "Matrícula": "1256137",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-12-21",
      "Fim": "2025-12-30"
    },
    {
      "Nome": "Diego Silva Veloso (Diego Veloso)",
      "Matrícula": "1971084",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-02-13",
      "Fim": "2025-02-13"
    },
    {
      "Nome": "Diego Silva Veloso (Diego Veloso)",
      "Matrícula": "1971084",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-03-22",
      "Fim": "2025-03-31"
    },
    {
      "Nome": "Diego Silva Veloso (Diego Veloso)",
      "Matrícula": "1971084",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência ?",
      "Início": "2025-04-06",
      "Fim": "2025-04-26"
    },
    {
      "Nome": "Diego Silva Veloso (Diego Veloso)",
      "Matrícula": "1971084",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-07-11",
      "Fim": "2025-07-20"
    },
    {
      "Nome": "Diego Silva Veloso (Diego Veloso)",
      "Matrícula": "1971084",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-21",
      "Fim": "2025-08-21"
    },
    {
      "Nome": "Diego Silva Veloso (Diego Veloso)",
      "Matrícula": "1971084",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-09-28",
      "Fim": "2025-09-28"
    },
    {
      "Nome": "Diego Silva Veloso (Diego Veloso)",
      "Matrícula": "1971084",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-06",
      "Fim": "2025-10-06"
    },
    {
      "Nome": "Diego Silva Veloso (Diego Veloso)",
      "Matrícula": "1971084",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-11-19",
      "Fim": "2025-11-19"
    },
    {
      "Nome": "Diego Silva Veloso (Diego Veloso)",
      "Matrícula": "1971084",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-12-01",
      "Fim": "2025-12-10"
    },
    {
      "Nome": "Diego Silva Veloso (Diego Veloso)",
      "Matrícula": "1971084",
      "Lotação": "NPF/DEL03-DF",
      "Código": "43",
      "Sigla": "AFVISPACOL",
      "Descrição": "Afas. Viagem/Serv País Com Ônus Limit. - EST Permite Frequência ?",
      "Início": "2025-12-15",
      "Fim": "2025-12-19"
    },
    {
      "Nome": "Douglas Brioschi Silva (Brioschi)",
      "Matrícula": "3312878",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-06-12",
      "Fim": "2025-06-18"
    },
    {
      "Nome": "Emerson Leandro dos Santos Borges (Emerson Borges)",
      "Matrícula": "1351033",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-06-30",
      "Fim": "2025-07-09"
    },
    {
      "Nome": "Emerson Leandro dos Santos Borges (Emerson Borges)",
      "Matrícula": "1351033",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-13",
      "Fim": "2025-10-13"
    },
    {
      "Nome": "Emerson Leandro dos Santos Borges (Emerson Borges)",
      "Matrícula": "1351033",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-10-15",
      "Fim": "2025-10-24"
    },
    {
      "Nome": "Emerson Leandro dos Santos Borges (Emerson Borges)",
      "Matrícula": "1351033",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-12-01",
      "Fim": "2025-12-04"
    },
    {
      "Nome": "Emerson Leandro dos Santos Borges (Emerson Borges)",
      "Matrícula": "1351033",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-12-22",
      "Fim": "2025-12-31"
    },
    {
      "Nome": "Erick Luiz Nunes Zardo (Zardo)",
      "Matrícula": "1785998",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência",
      "Início": "2025-01-25",
      "Fim": "2025-01-26"
    },
    {
      "Nome": "Erick Luiz Nunes Zardo (Zardo)",
      "Matrícula": "1785998",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-01-29",
      "Fim": "2025-02-06"
    },
    {
      "Nome": "Erick Luiz Nunes Zardo (Zardo)",
      "Matrícula": "1785998",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-02-26",
      "Fim": "2025-02-26"
    },
    {
      "Nome": "Erick Luiz Nunes Zardo (Zardo)",
      "Matrícula": "1785998",
      "Lotação": "NPF/DEL03-DF",
      "Código": "81",
      "Sigla": "LICCPACITA",
      "Descrição": "Lic. Capacitação - EST NÃO Permite Frequência ?",
      "Início": "2025-04-02",
      "Fim": "2025-06-30"
    },
    {
      "Nome": "Erick Luiz Nunes Zardo (Zardo)",
      "Matrícula": "1785998",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-07-22",
      "Fim": "2025-07-29"
    },
    {
      "Nome": "Erick Luiz Nunes Zardo (Zardo)",
      "Matrícula": "1785998",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-31",
      "Fim": "2025-08-31"
    },
    {
      "Nome": "Erick Luiz Nunes Zardo (Zardo)",
      "Matrícula": "1785998",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-09-18",
      "Fim": "2025-09-18"
    },
    {
      "Nome": "Erick Luiz Nunes Zardo (Zardo)",
      "Matrícula": "1785998",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-09-26",
      "Fim": "2025-09-26"
    },
    {
      "Nome": "Erick Luiz Nunes Zardo (Zardo)",
      "Matrícula": "1785998",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-11-21",
      "Fim": "2025-11-21"
    },
    {
      "Nome": "Erick Luiz Nunes Zardo (Zardo)",
      "Matrícula": "1785998",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-11-25",
      "Fim": "2025-11-25"
    },
    {
      "Nome": "Erick Luiz Nunes Zardo (Zardo)",
      "Matrícula": "1785998",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-12-03",
      "Fim": "2025-12-15"
    },
    {
      "Nome": "Fabricio Dantas Teixeira (F. Dantas)",
      "Matrícula": "3157514",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-01-15",
      "Fim": "2025-01-24"
    },
    {
      "Nome": "Fabricio Dantas Teixeira (F. Dantas)",
      "Matrícula": "3157514",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência",
      "Início": "2025-01-27",
      "Fim": "2025-01-28"
    },
    {
      "Nome": "Fabricio Dantas Teixeira (F. Dantas)",
      "Matrícula": "3157514",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência",
      "Início": "2025-01-31",
      "Fim": "2025-02-01"
    },
    {
      "Nome": "Fabricio Dantas Teixeira (F. Dantas)",
      "Matrícula": "3157514",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-02-04",
      "Fim": "2025-02-04"
    },
    {
      "Nome": "Fabricio Dantas Teixeira (F. Dantas)",
      "Matrícula": "3157514",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-02-15",
      "Fim": "2025-02-16"
    },
    {
      "Nome": "Fabricio Dantas Teixeira (F. Dantas)",
      "Matrícula": "3157514",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-03-28",
      "Fim": "2025-03-28"
    },
    {
      "Nome": "Fabricio Dantas Teixeira (F. Dantas)",
      "Matrícula": "3157514",
      "Lotação": "NPF/DEL03-DF",
      "Código": "81",
      "Sigla": "LICCPACITA",
      "Descrição": "Lic. Capacitação - EST NÃO Permite Frequência",
      "Início": "2025-04-02",
      "Fim": "2025-06-30"
    },
    {
      "Nome": "Fabricio Dantas Teixeira (F. Dantas)",
      "Matrícula": "3157514",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-07-02",
      "Fim": "2025-07-11"
    },
    {
      "Nome": "Fabricio Dantas Teixeira (F. Dantas)",
      "Matrícula": "3157514",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-07-12",
      "Fim": "2025-07-15"
    },
    {
      "Nome": "Fabricio Dantas Teixeira (F. Dantas)",
      "Matrícula": "3157514",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-11",
      "Fim": "2025-08-11"
    },
    {
      "Nome": "Fabricio Dantas Teixeira (F. Dantas)",
      "Matrícula": "3157514",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-09-12",
      "Fim": "2025-09-21"
    },
    {
      "Nome": "Fabricio Dantas Teixeira (F. Dantas)",
      "Matrícula": "3157514",
      "Lotação": "NPF/DEL03-DF",
      "Código": "90",
      "Sigla": "LICMDPEFAM",
      "Descrição": "Lic. por Motivo de Doença em Pesssoa da Família - EST NÃO Permite Frequência",
      "Início": "2025-10-22",
      "Fim": "2025-10-24"
    },
    {
      "Nome": "Fabricio Dantas Teixeira (F. Dantas)",
      "Matrícula": "3157514",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-29",
      "Fim": "2025-10-29"
    },
    {
      "Nome": "Fabricio Dantas Teixeira (F. Dantas)",
      "Matrícula": "3157514",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-11-15",
      "Fim": "2025-11-15"
    },
    {
      "Nome": "Fabricio Dantas Teixeira (F. Dantas)",
      "Matrícula": "3157514",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2026-01-01",
      "Fim": "2026-01-10"
    },
    {
      "Nome": "Felipe Borges de Oliveira (Oliveira V)",
      "Matrícula": "3211718",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2024-12-30",
      "Fim": "2025-01-14"
    },
    {
      "Nome": "Felipe Borges de Oliveira (Oliveira V)",
      "Matrícula": "3211718",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência",
      "Início": "2025-01-19",
      "Fim": "2025-01-20"
    },
    {
      "Nome": "Felipe Borges de Oliveira (Oliveira V)",
      "Matrícula": "3211718",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência",
      "Início": "2025-01-23",
      "Fim": "2025-01-24"
    },
    {
      "Nome": "Felipe Borges de Oliveira (Oliveira V)",
      "Matrícula": "3211718",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-02-08",
      "Fim": "2025-02-08"
    },
    {
      "Nome": "Felipe Borges de Oliveira (Oliveira V)",
      "Matrícula": "3211718",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-02-16",
      "Fim": "2025-02-16"
    },
    {
      "Nome": "Felipe Borges de Oliveira (Oliveira V)",
      "Matrícula": "3211718",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-03-08",
      "Fim": "2025-03-08"
    },
    {
      "Nome": "Felipe Borges de Oliveira (Oliveira V)",
      "Matrícula": "3211718",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-03-24",
      "Fim": "2025-03-28"
    },
    {
      "Nome": "Felipe Borges de Oliveira (Oliveira V)",
      "Matrícula": "3211718",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência",
      "Início": "2025-04-14",
      "Fim": "2025-05-02"
    },
    {
      "Nome": "Felipe Borges de Oliveira (Oliveira V)",
      "Matrícula": "3211718",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-03",
      "Fim": "2025-05-03"
    },
    {
      "Nome": "Felipe Borges de Oliveira (Oliveira V)",
      "Matrícula": "3211718",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-11",
      "Fim": "2025-05-11"
    },
    {
      "Nome": "Felipe Borges de Oliveira (Oliveira V)",
      "Matrícula": "3211718",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-23",
      "Fim": "2025-05-23"
    },
    {
      "Nome": "Felipe Borges de Oliveira (Oliveira V)",
      "Matrícula": "3211718",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-08",
      "Fim": "2025-06-08"
    },
    {
      "Nome": "Felipe Borges de Oliveira (Oliveira V)",
      "Matrícula": "3211718",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-07-10",
      "Fim": "2025-07-14"
    },
    {
      "Nome": "Felipe Borges de Oliveira (Oliveira V)",
      "Matrícula": "3211718",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-07-26",
      "Fim": "2025-07-26"
    },
    {
      "Nome": "Felipe Borges de Oliveira (Oliveira V)",
      "Matrícula": "3211718",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-27",
      "Fim": "2025-08-27"
    },
    {
      "Nome": "Felipe Borges de Oliveira (Oliveira V)",
      "Matrícula": "3211718",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-31",
      "Fim": "2025-08-31"
    },
    {
      "Nome": "Felipe Borges de Oliveira (Oliveira V)",
      "Matrícula": "3211718",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência",
      "Início": "2025-10-04",
      "Fim": "2025-12-05"
    },
    {
      "Nome": "Felipe Borges de Oliveira (Oliveira V)",
      "Matrícula": "3211718",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-12-29",
      "Fim": "2026-01-17"
    },
    {
      "Nome": "Felipe de Sena Lopes (F. Lopes)",
      "Matrícula": "3159621",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-01-29",
      "Fim": "2025-01-31"
    },
    {
      "Nome": "Felipe de Sena Lopes (F. Lopes)",
      "Matrícula": "3159621",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência",
      "Início": "2025-04-01",
      "Fim": "2025-04-01"
    },
    {
      "Nome": "Felipe de Sena Lopes (F. Lopes)",
      "Matrícula": "3159621",
      "Lotação": "NPF/DEL03-DF",
      "Código": "81",
      "Sigla": "LICCPACITA",
      "Descrição": "Lic. Capacitação - EST NÃO Permite Frequência",
      "Início": "2025-04-02",
      "Fim": "2025-04-30"
    },
    {
      "Nome": "Felipe de Sena Lopes (F. Lopes)",
      "Matrícula": "3159621",
      "Lotação": "NPF/DEL03-DF",
      "Código": "81",
      "Sigla": "LICCPACITA",
      "Descrição": "Lic. Capacitação - EST NÃO Permite Frequência",
      "Início": "2025-05-01",
      "Fim": "2025-05-31"
    },
    {
      "Nome": "Felipe de Sena Lopes (F. Lopes)",
      "Matrícula": "3159621",
      "Lotação": "NPF/DEL03-DF",
      "Código": "81",
      "Sigla": "LICCPACITA",
      "Descrição": "Lic. Capacitação - EST NÃO Permite Frequência",
      "Início": "2025-06-01",
      "Fim": "2025-06-30"
    },
    {
      "Nome": "Felipe de Sena Lopes (F. Lopes)",
      "Matrícula": "3159621",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-09-20",
      "Fim": "2025-09-20"
    },
    {
      "Nome": "Felipe de Sena Lopes (F. Lopes)",
      "Matrícula": "3159621",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência",
      "Início": "2025-09-30",
      "Fim": "2025-10-03"
    },
    {
      "Nome": "Felipe de Sena Lopes (F. Lopes)",
      "Matrícula": "3159621",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-26",
      "Fim": "2025-10-26"
    },
    {
      "Nome": "Felipe de Sena Lopes (F. Lopes)",
      "Matrícula": "3159621",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-11-11",
      "Fim": "2025-11-11"
    },
    {
      "Nome": "Felipe de Sena Lopes (F. Lopes)",
      "Matrícula": "3159621",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-12-13",
      "Fim": "2025-12-25"
    },
    {
      "Nome": "Felipe de Sena Lopes (F. Lopes)",
      "Matrícula": "3159621",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-12-29",
      "Fim": "2025-12-29"
    },
    {
      "Nome": "Felipe Motta Camarinha (F. Camarinha)",
      "Matrícula": "1103063",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-02-16",
      "Fim": "2025-02-16"
    },
    {
      "Nome": "Felipe Motta Camarinha (F. Camarinha)",
      "Matrícula": "1103063",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-02-24",
      "Fim": "2025-02-24"
    },
    {
      "Nome": "Felipe Motta Camarinha (F. Camarinha)",
      "Matrícula": "1103063",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-03-28",
      "Fim": "2025-03-28"
    },
    {
      "Nome": "Felipe Motta Camarinha (F. Camarinha)",
      "Matrícula": "1103063",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-04-01",
      "Fim": "2025-04-05"
    },
    {
      "Nome": "Felipe Motta Camarinha (F. Camarinha)",
      "Matrícula": "1103063",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-04-09",
      "Fim": "2025-04-09"
    },
    {
      "Nome": "Felipe Motta Camarinha (F. Camarinha)",
      "Matrícula": "1103063",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência",
      "Início": "2025-04-14",
      "Fim": "2025-05-02"
    },
    {
      "Nome": "Felipe Motta Camarinha (F. Camarinha)",
      "Matrícula": "1103063",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-15",
      "Fim": "2025-05-15"
    },
    {
      "Nome": "Felipe Motta Camarinha (F. Camarinha)",
      "Matrícula": "1103063",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-23",
      "Fim": "2025-05-23"
    },
    {
      "Nome": "Felipe Motta Camarinha (F. Camarinha)",
      "Matrícula": "1103063",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-27",
      "Fim": "2025-05-27"
    },
    {
      "Nome": "Felipe Motta Camarinha (F. Camarinha)",
      "Matrícula": "1103063",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-04",
      "Fim": "2025-06-04"
    },
    {
      "Nome": "Felipe Motta Camarinha (F. Camarinha)",
      "Matrícula": "1103063",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência ?",
      "Início": "2025-06-27",
      "Fim": "2025-07-10"
    },
    {
      "Nome": "Felipe Motta Camarinha (F. Camarinha)",
      "Matrícula": "1103063",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-28",
      "Fim": "2025-06-28"
    },
    {
      "Nome": "Felipe Motta Camarinha (F. Camarinha)",
      "Matrícula": "1103063",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-07-22",
      "Fim": "2025-07-22"
    },
    {
      "Nome": "Felipe Motta Camarinha (F. Camarinha)",
      "Matrícula": "1103063",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-07-30",
      "Fim": "2025-07-30"
    },
    {
      "Nome": "Felipe Motta Camarinha (F. Camarinha)",
      "Matrícula": "1103063",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-11",
      "Fim": "2025-08-11"
    },
    {
      "Nome": "Felipe Motta Camarinha (F. Camarinha)",
      "Matrícula": "1103063",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-23",
      "Fim": "2025-08-23"
    },
    {
      "Nome": "Felipe Motta Camarinha (F. Camarinha)",
      "Matrícula": "1103063",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-09-04",
      "Fim": "2025-09-04"
    },
    {
      "Nome": "Felipe Motta Camarinha (F. Camarinha)",
      "Matrícula": "1103063",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-09-24",
      "Fim": "2025-09-24"
    },
    {
      "Nome": "Felipe Motta Camarinha (F. Camarinha)",
      "Matrícula": "1103063",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência",
      "Início": "2025-09-30",
      "Fim": "2025-10-03"
    },
    {
      "Nome": "Felipe Motta Camarinha (F. Camarinha)",
      "Matrícula": "1103063",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-02",
      "Fim": "2025-10-02"
    },
    {
      "Nome": "Felipe Motta Camarinha (F. Camarinha)",
      "Matrícula": "1103063",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-10-06",
      "Fim": "2025-10-15"
    },
    {
      "Nome": "Felipe Motta Camarinha (F. Camarinha)",
      "Matrícula": "1103063",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-11-03",
      "Fim": "2025-11-03"
    },
    {
      "Nome": "Felipe Motta Camarinha (F. Camarinha)",
      "Matrícula": "1103063",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência ?",
      "Início": "2025-11-05",
      "Fim": "2025-11-25"
    },
    {
      "Nome": "Felipe Motta Camarinha (F. Camarinha)",
      "Matrícula": "1103063",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-11-15",
      "Fim": "2025-11-15"
    },
    {
      "Nome": "Felipe Motta Camarinha (F. Camarinha)",
      "Matrícula": "1103063",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-11-27",
      "Fim": "2025-11-27"
    },
    {
      "Nome": "Felipe Motta Camarinha (F. Camarinha)",
      "Matrícula": "1103063",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-12-01",
      "Fim": "2025-12-01"
    },
    {
      "Nome": "Felipe Motta Camarinha (F. Camarinha)",
      "Matrícula": "1103063",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-12-05",
      "Fim": "2025-12-19"
    },
    {
      "Nome": "Fernando Colafranceschi da Silva (Colafranceschi)",
      "Matrícula": "3211716",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-01-04",
      "Fim": "2025-01-08"
    },
    {
      "Nome": "Fernando Colafranceschi da Silva (Colafranceschi)",
      "Matrícula": "3211716",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-02-01",
      "Fim": "2025-02-01"
    },
    {
      "Nome": "Fernando Colafranceschi da Silva (Colafranceschi)",
      "Matrícula": "3211716",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-02-25",
      "Fim": "2025-02-25"
    },
    {
      "Nome": "Fernando Colafranceschi da Silva (Colafranceschi)",
      "Matrícula": "3211716",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-03-01",
      "Fim": "2025-03-17"
    },
    {
      "Nome": "Fernando Colafranceschi da Silva (Colafranceschi)",
      "Matrícula": "3211716",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-21",
      "Fim": "2025-06-21"
    },
    {
      "Nome": "Fernando Colafranceschi da Silva (Colafranceschi)",
      "Matrícula": "3211716",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-06-29",
      "Fim": "2025-06-29"
    },
    {
      "Nome": "Fernando Colafranceschi da Silva (Colafranceschi)",
      "Matrícula": "3211716",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-07-31",
      "Fim": "2025-07-31"
    },
    {
      "Nome": "Fernando Colafranceschi da Silva (Colafranceschi)",
      "Matrícula": "3211716",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-08",
      "Fim": "2025-08-08"
    },
    {
      "Nome": "Fernando Colafranceschi da Silva (Colafranceschi)",
      "Matrícula": "3211716",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-21",
      "Fim": "2025-08-21"
    },
    {
      "Nome": "Fernando Colafranceschi da Silva (Colafranceschi)",
      "Matrícula": "3211716",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-09-05",
      "Fim": "2025-09-05"
    },
    {
      "Nome": "Fernando Colafranceschi da Silva (Colafranceschi)",
      "Matrícula": "3211716",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-03",
      "Fim": "2025-10-03"
    },
    {
      "Nome": "Fernando Colafranceschi da Silva (Colafranceschi)",
      "Matrícula": "3211716",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência",
      "Início": "2025-10-05",
      "Fim": "2025-11-16"
    },
    {
      "Nome": "Fernando Colafranceschi da Silva (Colafranceschi)",
      "Matrícula": "3211716",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-11-20",
      "Fim": "2025-11-20"
    },
    {
      "Nome": "Fernando Colafranceschi da Silva (Colafranceschi)",
      "Matrícula": "3211716",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-11-24",
      "Fim": "2025-11-24"
    },
    {
      "Nome": "Fernando Colafranceschi da Silva (Colafranceschi)",
      "Matrícula": "3211716",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-12-01",
      "Fim": "2025-12-08"
    },
    {
      "Nome": "Fernando Trevizolo de Souza (Trevizolo)",
      "Matrícula": "1777933",
      "Lotação": "NPF/DEL03-DF",
      "Código": "81",
      "Sigla": "LICCPACITA",
      "Descrição": "Lic. Capacitação - EST NÃO Permite Frequência",
      "Início": "2025-01-02",
      "Fim": "2025-04-01"
    },
    {
      "Nome": "Fernando Trevizolo de Souza (Trevizolo)",
      "Matrícula": "1777933",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-04-05",
      "Fim": "2025-04-05"
    },
    {
      "Nome": "Fernando Trevizolo de Souza (Trevizolo)",
      "Matrícula": "1777933",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-04-09",
      "Fim": "2025-04-09"
    },
    {
      "Nome": "Fernando Trevizolo de Souza (Trevizolo)",
      "Matrícula": "1777933",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-05-03",
      "Fim": "2025-05-12"
    },
    {
      "Nome": "Fernando Trevizolo de Souza (Trevizolo)",
      "Matrícula": "1777933",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-05-23",
      "Fim": "2025-05-23"
    },
    {
      "Nome": "Fernando Trevizolo de Souza (Trevizolo)",
      "Matrícula": "1777933",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-06-20",
      "Fim": "2025-07-19"
    },
    {
      "Nome": "Fernando Trevizolo de Souza (Trevizolo)",
      "Matrícula": "1777933",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-07-21",
      "Fim": "2025-08-09"
    },
    {
      "Nome": "Fernando Trevizolo de Souza (Trevizolo)",
      "Matrícula": "1777933",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-08-01",
      "Fim": "2025-08-30"
    },
    {
      "Nome": "Fernando Trevizolo de Souza (Trevizolo)",
      "Matrícula": "1777933",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-09-01",
      "Fim": "2025-09-30"
    },
    {
      "Nome": "Fernando Trevizolo de Souza (Trevizolo)",
      "Matrícula": "1777933",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-01",
      "Fim": "2025-10-01"
    },
    {
      "Nome": "Fernando Trevizolo de Souza (Trevizolo)",
      "Matrícula": "1777933",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-11-10",
      "Fim": "2025-11-10"
    },
    {
      "Nome": "Guilherme Barbosa de Carvalho (Guilherme Carvalho)",
      "Matrícula": "3300578",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-03-11",
      "Fim": "2025-03-11"
    },
    {
      "Nome": "Guilherme Barbosa de Carvalho (Guilherme Carvalho)",
      "Matrícula": "3300578",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-03-19",
      "Fim": "2025-03-19"
    },
    {
      "Nome": "Guilherme Barbosa de Carvalho (Guilherme Carvalho)",
      "Matrícula": "3300578",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-04-02",
      "Fim": "2025-04-02"
    },
    {
      "Nome": "Guilherme Barbosa de Carvalho (Guilherme Carvalho)",
      "Matrícula": "3300578",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-04-28",
      "Fim": "2025-05-01"
    },
    {
      "Nome": "Guilherme Barbosa de Carvalho (Guilherme Carvalho)",
      "Matrícula": "3300578",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-05-07",
      "Fim": "2025-05-09"
    },
    {
      "Nome": "Guilherme Barbosa de Carvalho (Guilherme Carvalho)",
      "Matrícula": "3300578",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-05-12",
      "Fim": "2025-05-31"
    },
    {
      "Nome": "Guilherme Barbosa de Carvalho (Guilherme Carvalho)",
      "Matrícula": "3300578",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-01",
      "Fim": "2025-06-01"
    },
    {
      "Nome": "Guilherme Barbosa de Carvalho (Guilherme Carvalho)",
      "Matrícula": "3300578",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-06-06",
      "Fim": "2025-06-09"
    },
    {
      "Nome": "Guilherme Barbosa de Carvalho (Guilherme Carvalho)",
      "Matrícula": "3300578",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-25",
      "Fim": "2025-06-25"
    },
    {
      "Nome": "Guilherme Barbosa de Carvalho (Guilherme Carvalho)",
      "Matrícula": "3300578",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-07-03",
      "Fim": "2025-07-03"
    },
    {
      "Nome": "Guilherme Barbosa de Carvalho (Guilherme Carvalho)",
      "Matrícula": "3300578",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-04",
      "Fim": "2025-08-04"
    },
    {
      "Nome": "Guilherme Barbosa de Carvalho (Guilherme Carvalho)",
      "Matrícula": "3300578",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-08-06",
      "Fim": "2025-08-09"
    },
    {
      "Nome": "Guilherme Barbosa de Carvalho (Guilherme Carvalho)",
      "Matrícula": "3300578",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-28",
      "Fim": "2025-08-28"
    },
    {
      "Nome": "Guilherme Barbosa de Carvalho (Guilherme Carvalho)",
      "Matrícula": "3300578",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-09-05",
      "Fim": "2025-09-22"
    },
    {
      "Nome": "Guilherme Barbosa de Carvalho (Guilherme Carvalho)",
      "Matrícula": "3300578",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-09-25",
      "Fim": "2025-09-25"
    },
    {
      "Nome": "Guilherme Barbosa de Carvalho (Guilherme Carvalho)",
      "Matrícula": "3300578",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-10-04",
      "Fim": "2025-10-06"
    },
    {
      "Nome": "Guilherme Barbosa de Carvalho (Guilherme Carvalho)",
      "Matrícula": "3300578",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-31",
      "Fim": "2025-10-31"
    },
    {
      "Nome": "Guilherme Barbosa de Carvalho (Guilherme Carvalho)",
      "Matrícula": "3300578",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-12-05",
      "Fim": "2025-12-07"
    },
    {
      "Nome": "Guilherme Barbosa de Carvalho (Guilherme Carvalho)",
      "Matrícula": "3300578",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-12-14",
      "Fim": "2025-12-14"
    },
    {
      "Nome": "Guilherme Barbosa de Carvalho (Guilherme Carvalho)",
      "Matrícula": "3300578",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2026-01-03",
      "Fim": "2026-01-03"
    },
    {
      "Nome": "Guilherme Costa Neri (C. Neri)",
      "Matrícula": "1716152",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-01-18",
      "Fim": "2025-01-18"
    },
    {
      "Nome": "Guilherme Costa Neri (C. Neri)",
      "Matrícula": "1716152",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-02-11",
      "Fim": "2025-02-11"
    },
    {
      "Nome": "Guilherme Costa Neri (C. Neri)",
      "Matrícula": "1716152",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-02-19",
      "Fim": "2025-02-19"
    },
    {
      "Nome": "Guilherme Costa Neri (C. Neri)",
      "Matrícula": "1716152",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-02-27",
      "Fim": "2025-03-02"
    },
    {
      "Nome": "Guilherme Costa Neri (C. Neri)",
      "Matrícula": "1716152",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-04-04",
      "Fim": "2025-04-04"
    },
    {
      "Nome": "Guilherme Costa Neri (C. Neri)",
      "Matrícula": "1716152",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-04-12",
      "Fim": "2025-04-13"
    },
    {
      "Nome": "Guilherme Costa Neri (C. Neri)",
      "Matrícula": "1716152",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-04-15",
      "Fim": "2025-04-18"
    },
    {
      "Nome": "Guilherme Costa Neri (C. Neri)",
      "Matrícula": "1716152",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-18",
      "Fim": "2025-05-18"
    },
    {
      "Nome": "Guilherme Costa Neri (C. Neri)",
      "Matrícula": "1716152",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-07",
      "Fim": "2025-06-07"
    },
    {
      "Nome": "Guilherme Costa Neri (C. Neri)",
      "Matrícula": "1716152",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-07-01",
      "Fim": "2025-07-01"
    },
    {
      "Nome": "Guilherme Costa Neri (C. Neri)",
      "Matrícula": "1716152",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-07-05",
      "Fim": "2025-07-13"
    },
    {
      "Nome": "Guilherme Costa Neri (C. Neri)",
      "Matrícula": "1716152",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-07-25",
      "Fim": "2025-07-25"
    },
    {
      "Nome": "Guilherme Costa Neri (C. Neri)",
      "Matrícula": "1716152",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-18",
      "Fim": "2025-08-18"
    },
    {
      "Nome": "Guilherme Costa Neri (C. Neri)",
      "Matrícula": "1716152",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-22",
      "Fim": "2025-08-22"
    },
    {
      "Nome": "Guilherme Costa Neri (C. Neri)",
      "Matrícula": "1716152",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-09-11",
      "Fim": "2025-09-12"
    },
    {
      "Nome": "Guilherme Costa Neri (C. Neri)",
      "Matrícula": "1716152",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-05",
      "Fim": "2025-10-05"
    },
    {
      "Nome": "Guilherme Costa Neri (C. Neri)",
      "Matrícula": "1716152",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-13",
      "Fim": "2025-10-13"
    },
    {
      "Nome": "Guilherme Costa Neri (C. Neri)",
      "Matrícula": "1716152",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-10-21",
      "Fim": "2025-10-29"
    },
    {
      "Nome": "Guilherme Costa Neri (C. Neri)",
      "Matrícula": "1716152",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-11-18",
      "Fim": "2025-11-19"
    },
    {
      "Nome": "Guilherme Costa Neri (C. Neri)",
      "Matrícula": "1716152",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-12-01",
      "Fim": "2025-12-12"
    },
    {
      "Nome": "Guilherme Costa Neri (C. Neri)",
      "Matrícula": "1716152",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-12-28",
      "Fim": "2025-12-31"
    },
    {
      "Nome": "Gustavo de Almeida Scalia (Scalia)",
      "Matrícula": "1816085",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2024-12-16",
      "Fim": "2025-01-04"
    },
    {
      "Nome": "Gustavo de Almeida Scalia (Scalia)",
      "Matrícula": "1816085",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência",
      "Início": "2025-01-21",
      "Fim": "2025-01-22"
    },
    {
      "Nome": "Gustavo de Almeida Scalia (Scalia)",
      "Matrícula": "1816085",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-02-14",
      "Fim": "2025-02-14"
    },
    {
      "Nome": "Gustavo de Almeida Scalia (Scalia)",
      "Matrícula": "1816085",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-02-26",
      "Fim": "2025-03-07"
    },
    {
      "Nome": "Gustavo de Almeida Scalia (Scalia)",
      "Matrícula": "1816085",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-03-21",
      "Fim": "2025-03-23"
    },
    {
      "Nome": "Gustavo de Almeida Scalia (Scalia)",
      "Matrícula": "1816085",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-03-26",
      "Fim": "2025-03-26"
    },
    {
      "Nome": "Gustavo de Almeida Scalia (Scalia)",
      "Matrícula": "1816085",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência",
      "Início": "2025-04-23",
      "Fim": "2025-04-23"
    },
    {
      "Nome": "Gustavo de Almeida Scalia (Scalia)",
      "Matrícula": "1816085",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-05-06",
      "Fim": "2025-05-20"
    },
    {
      "Nome": "Gustavo de Almeida Scalia (Scalia)",
      "Matrícula": "1816085",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-05-16",
      "Fim": "2025-05-22"
    },
    {
      "Nome": "Gustavo de Almeida Scalia (Scalia)",
      "Matrícula": "1816085",
      "Lotação": "NPF/DEL03-DF",
      "Código": "90",
      "Sigla": "LICMDPEFAM",
      "Descrição": "Lic. por Motivo de Doença em Pesssoa da Família - EST NÃO Permite Frequência",
      "Início": "2025-05-27",
      "Fim": "2025-05-28"
    },
    {
      "Nome": "Gustavo de Almeida Scalia (Scalia)",
      "Matrícula": "1816085",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-22",
      "Fim": "2025-06-22"
    },
    {
      "Nome": "Gustavo de Almeida Scalia (Scalia)",
      "Matrícula": "1816085",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-07-08",
      "Fim": "2025-07-17"
    },
    {
      "Nome": "Gustavo de Almeida Scalia (Scalia)",
      "Matrícula": "1816085",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-13",
      "Fim": "2025-08-13"
    },
    {
      "Nome": "Gustavo de Almeida Scalia (Scalia)",
      "Matrícula": "1816085",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-29",
      "Fim": "2025-08-29"
    },
    {
      "Nome": "Gustavo de Almeida Scalia (Scalia)",
      "Matrícula": "1816085",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-09-02",
      "Fim": "2025-09-02"
    },
    {
      "Nome": "Gustavo de Almeida Scalia (Scalia)",
      "Matrícula": "1816085",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-09-10",
      "Fim": "2025-09-10"
    },
    {
      "Nome": "Gustavo de Almeida Scalia (Scalia)",
      "Matrícula": "1816085",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-24",
      "Fim": "2025-10-24"
    },
    {
      "Nome": "Gustavo de Almeida Scalia (Scalia)",
      "Matrícula": "1816085",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-11-05",
      "Fim": "2025-11-05"
    },
    {
      "Nome": "Gustavo de Almeida Scalia (Scalia)",
      "Matrícula": "1816085",
      "Lotação": "NPF/DEL03-DF",
      "Código": "90",
      "Sigla": "LICMDPEFAM",
      "Descrição": "Lic. por Motivo de Doença em Pesssoa da Família - EST NÃO Permite Frequência",
      "Início": "2025-12-06",
      "Fim": "2025-12-13"
    },
    {
      "Nome": "Gustavo de Almeida Scalia (Scalia)",
      "Matrícula": "1816085",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-12-22",
      "Fim": "2025-12-31"
    },
    {
      "Nome": "Honorato Ferreira da Silva Junior (Honorato)",
      "Matrícula": "1821004",
      "Lotação": "NPF/DEL03-DF",
      "Código": "324",
      "Sigla": "LICPATPROR",
      "Descrição": "Lic. Paternidade Prorrogação - EST NÃO Permite Frequência",
      "Início": "2024-12-23",
      "Fim": "2025-01-06"
    },
    {
      "Nome": "Honorato Ferreira da Silva Junior (Honorato)",
      "Matrícula": "1821004",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência",
      "Início": "2025-01-13",
      "Fim": "2025-01-14"
    },
    {
      "Nome": "Honorato Ferreira da Silva Junior (Honorato)",
      "Matrícula": "1821004",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência",
      "Início": "2025-01-17",
      "Fim": "2025-01-18"
    },
    {
      "Nome": "Honorato Ferreira da Silva Junior (Honorato)",
      "Matrícula": "1821004",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência",
      "Início": "2025-01-21",
      "Fim": "2025-01-22"
    },
    {
      "Nome": "Honorato Ferreira da Silva Junior (Honorato)",
      "Matrícula": "1821004",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência",
      "Início": "2025-01-25",
      "Fim": "2025-01-26"
    },
    {
      "Nome": "Honorato Ferreira da Silva Junior (Honorato)",
      "Matrícula": "1821004",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência",
      "Início": "2025-01-29",
      "Fim": "2025-01-30"
    },
    {
      "Nome": "Honorato Ferreira da Silva Junior (Honorato)",
      "Matrícula": "1821004",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-02-10",
      "Fim": "2025-02-19"
    },
    {
      "Nome": "Honorato Ferreira da Silva Junior (Honorato)",
      "Matrícula": "1821004",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-04-02",
      "Fim": "2025-04-11"
    },
    {
      "Nome": "Honorato Ferreira da Silva Junior (Honorato)",
      "Matrícula": "1821004",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-02",
      "Fim": "2025-06-02"
    },
    {
      "Nome": "Honorato Ferreira da Silva Junior (Honorato)",
      "Matrícula": "1821004",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-26",
      "Fim": "2025-06-26"
    },
    {
      "Nome": "Honorato Ferreira da Silva Junior (Honorato)",
      "Matrícula": "1821004",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-07-03",
      "Fim": "2025-08-01"
    },
    {
      "Nome": "Honorato Ferreira da Silva Junior (Honorato)",
      "Matrícula": "1821004",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-07-28",
      "Fim": "2025-07-28"
    },
    {
      "Nome": "Honorato Ferreira da Silva Junior (Honorato)",
      "Matrícula": "1821004",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-08-04",
      "Fim": "2025-08-13"
    },
    {
      "Nome": "Honorato Ferreira da Silva Junior (Honorato)",
      "Matrícula": "1821004",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-17",
      "Fim": "2025-08-17"
    },
    {
      "Nome": "Honorato Ferreira da Silva Junior (Honorato)",
      "Matrícula": "1821004",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-21",
      "Fim": "2025-08-21"
    },
    {
      "Nome": "Honorato Ferreira da Silva Junior (Honorato)",
      "Matrícula": "1821004",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-09-02",
      "Fim": "2025-09-02"
    },
    {
      "Nome": "Honorato Ferreira da Silva Junior (Honorato)",
      "Matrícula": "1821004",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-09-06",
      "Fim": "2025-09-06"
    },
    {
      "Nome": "Honorato Ferreira da Silva Junior (Honorato)",
      "Matrícula": "1821004",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-10-08",
      "Fim": "2025-10-17"
    },
    {
      "Nome": "Honorato Ferreira da Silva Junior (Honorato)",
      "Matrícula": "1821004",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-11-17",
      "Fim": "2025-11-17"
    },
    {
      "Nome": "Honorato Ferreira da Silva Junior (Honorato)",
      "Matrícula": "1821004",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-11-29",
      "Fim": "2025-11-29"
    },
    {
      "Nome": "Jardel Joaquim Rodrigues (Jardel Rodrigues)",
      "Matrícula": "1585564",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2024-12-31",
      "Fim": "2025-01-09"
    },
    {
      "Nome": "Jardel Joaquim Rodrigues (Jardel Rodrigues)",
      "Matrícula": "1585564",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-01-31",
      "Fim": "2025-02-09"
    },
    {
      "Nome": "Jardel Joaquim Rodrigues (Jardel Rodrigues)",
      "Matrícula": "1585564",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-02-15",
      "Fim": "2025-02-15"
    },
    {
      "Nome": "Jardel Joaquim Rodrigues (Jardel Rodrigues)",
      "Matrícula": "1585564",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência ?",
      "Início": "2025-02-22",
      "Fim": "2025-03-08"
    },
    {
      "Nome": "Jardel Joaquim Rodrigues (Jardel Rodrigues)",
      "Matrícula": "1585564",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-03-15",
      "Fim": "2025-03-15"
    },
    {
      "Nome": "Jardel Joaquim Rodrigues (Jardel Rodrigues)",
      "Matrícula": "1585564",
      "Lotação": "NPF/DEL03-DF",
      "Código": "32",
      "Sigla": "AFTRPPTPOL",
      "Descrição": "Afas. Est/Prog.Trein.(Congr-Encon) País C/Ônus Limit - EST NÃO Permite Frequência ?",
      "Início": "2025-04-08",
      "Fim": "2025-04-11"
    },
    {
      "Nome": "Jardel Joaquim Rodrigues (Jardel Rodrigues)",
      "Matrícula": "1585564",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência ?",
      "Início": "2025-04-12",
      "Fim": "2025-05-02"
    },
    {
      "Nome": "Jardel Joaquim Rodrigues (Jardel Rodrigues)",
      "Matrícula": "1585564",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-06",
      "Fim": "2025-05-06"
    },
    {
      "Nome": "Jardel Joaquim Rodrigues (Jardel Rodrigues)",
      "Matrícula": "1585564",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-07",
      "Fim": "2025-05-07"
    },
    {
      "Nome": "Jardel Joaquim Rodrigues (Jardel Rodrigues)",
      "Matrícula": "1585564",
      "Lotação": "NPF/DEL03-DF",
      "Código": "352",
      "Sigla": "AUARGECC",
      "Descrição": "Ausência para Atividades Relacionadas à GECC - EST Permite Frequência ?",
      "Início": "2025-05-09",
      "Fim": "2025-05-09"
    },
    {
      "Nome": "Jardel Joaquim Rodrigues (Jardel Rodrigues)",
      "Matrícula": "1585564",
      "Lotação": "NPF/DEL03-DF",
      "Código": "352",
      "Sigla": "AUARGECC",
      "Descrição": "Ausência para Atividades Relacionadas à GECC - EST Permite Frequência ?",
      "Início": "2025-05-13",
      "Fim": "2025-05-13"
    },
    {
      "Nome": "Jardel Joaquim Rodrigues (Jardel Rodrigues)",
      "Matrícula": "1585564",
      "Lotação": "NPF/DEL03-DF",
      "Código": "352",
      "Sigla": "AUARGECC",
      "Descrição": "Ausência para Atividades Relacionadas à GECC - EST Permite Frequência ?",
      "Início": "2025-05-15",
      "Fim": "2025-05-15"
    },
    {
      "Nome": "Jardel Joaquim Rodrigues (Jardel Rodrigues)",
      "Matrícula": "1585564",
      "Lotação": "NPF/DEL03-DF",
      "Código": "32",
      "Sigla": "AFTRPPTPOL",
      "Descrição": "Afas. Est/Prog.Trein.(Congr-Encon) País C/Ônus Limit - EST NÃO Permite Frequência ?",
      "Início": "2025-05-19",
      "Fim": "2025-05-19"
    },
    {
      "Nome": "Jardel Joaquim Rodrigues (Jardel Rodrigues)",
      "Matrícula": "1585564",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-21",
      "Fim": "2025-05-21"
    },
    {
      "Nome": "Jardel Joaquim Rodrigues (Jardel Rodrigues)",
      "Matrícula": "1585564",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-23",
      "Fim": "2025-05-23"
    },
    {
      "Nome": "Jardel Joaquim Rodrigues (Jardel Rodrigues)",
      "Matrícula": "1585564",
      "Lotação": "NPF/DEL03-DF",
      "Código": "352",
      "Sigla": "AUARGECC",
      "Descrição": "Ausência para Atividades Relacionadas à GECC - EST Permite Frequência ?",
      "Início": "2025-05-27",
      "Fim": "2025-05-27"
    },
    {
      "Nome": "Jardel Joaquim Rodrigues (Jardel Rodrigues)",
      "Matrícula": "1585564",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-05",
      "Fim": "2025-06-05"
    },
    {
      "Nome": "Jardel Joaquim Rodrigues (Jardel Rodrigues)",
      "Matrícula": "1585564",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência ?",
      "Início": "2025-06-21",
      "Fim": "2025-07-09"
    },
    {
      "Nome": "Jardel Joaquim Rodrigues (Jardel Rodrigues)",
      "Matrícula": "1585564",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência ?",
      "Início": "2025-07-11",
      "Fim": "2025-07-15"
    },
    {
      "Nome": "Jardel Joaquim Rodrigues (Jardel Rodrigues)",
      "Matrícula": "1585564",
      "Lotação": "NPF/DEL03-DF",
      "Código": "32",
      "Sigla": "AFTRPPTPOL",
      "Descrição": "Afas. Est/Prog.Trein.(Congr-Encon) País C/Ônus Limit - EST NÃO Permite Frequência ?",
      "Início": "2025-07-16",
      "Fim": "2025-07-18"
    },
    {
      "Nome": "Jardel Joaquim Rodrigues (Jardel Rodrigues)",
      "Matrícula": "1585564",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência ?",
      "Início": "2025-07-28",
      "Fim": "2025-09-06"
    },
    {
      "Nome": "Jardel Joaquim Rodrigues (Jardel Rodrigues)",
      "Matrícula": "1585564",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-09-15",
      "Fim": "2025-09-15"
    },
    {
      "Nome": "Jardel Joaquim Rodrigues (Jardel Rodrigues)",
      "Matrícula": "1585564",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência ?",
      "Início": "2025-09-17",
      "Fim": "2025-10-01"
    },
    {
      "Nome": "Jardel Joaquim Rodrigues (Jardel Rodrigues)",
      "Matrícula": "1585564",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-07",
      "Fim": "2025-10-07"
    },
    {
      "Nome": "Jardel Joaquim Rodrigues (Jardel Rodrigues)",
      "Matrícula": "1585564",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-09",
      "Fim": "2025-10-09"
    },
    {
      "Nome": "Jardel Joaquim Rodrigues (Jardel Rodrigues)",
      "Matrícula": "1585564",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-15",
      "Fim": "2025-10-15"
    },
    {
      "Nome": "Jardel Joaquim Rodrigues (Jardel Rodrigues)",
      "Matrícula": "1585564",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência ?",
      "Início": "2025-10-19",
      "Fim": "2025-11-12"
    },
    {
      "Nome": "Jardel Joaquim Rodrigues (Jardel Rodrigues)",
      "Matrícula": "1585564",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência",
      "Início": "2025-11-24",
      "Fim": "2025-11-24"
    },
    {
      "Nome": "Jardel Joaquim Rodrigues (Jardel Rodrigues)",
      "Matrícula": "1585564",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-12-01",
      "Fim": "2025-12-15"
    },
    {
      "Nome": "Jardel Joaquim Rodrigues (Jardel Rodrigues)",
      "Matrícula": "1585564",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência",
      "Início": "2025-12-24",
      "Fim": "2025-12-24"
    },
    {
      "Nome": "Jardel Joaquim Rodrigues (Jardel Rodrigues)",
      "Matrícula": "1585564",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2026-01-01",
      "Fim": "2026-01-01"
    },
    {
      "Nome": "Jardel Joaquim Rodrigues (Jardel Rodrigues)",
      "Matrícula": "1585564",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência ?",
      "Início": "2026-01-02",
      "Fim": "2026-02-07"
    },
    {
      "Nome": "Jetson Jose da Silva (Jetson)",
      "Matrícula": "1396047",
      "Lotação": "NPF/DEL03-DF",
      "Código": "81",
      "Sigla": "LICCPACITA",
      "Descrição": "Lic. Capacitação - EST NÃO Permite Frequência",
      "Início": "2024-10-16",
      "Fim": "2025-01-15"
    },
    {
      "Nome": "Jetson Jose da Silva (Jetson)",
      "Matrícula": "1396047",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-01-15",
      "Fim": "2025-01-24"
    },
    {
      "Nome": "Jetson Jose da Silva (Jetson)",
      "Matrícula": "1396047",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-01-27",
      "Fim": "2025-02-05"
    },
    {
      "Nome": "Jetson Jose da Silva (Jetson)",
      "Matrícula": "1396047",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-03-24",
      "Fim": "2025-03-24"
    },
    {
      "Nome": "Jetson Jose da Silva (Jetson)",
      "Matrícula": "1396047",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-12",
      "Fim": "2025-05-12"
    },
    {
      "Nome": "Jetson Jose da Silva (Jetson)",
      "Matrícula": "1396047",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-06-02",
      "Fim": "2025-06-02"
    },
    {
      "Nome": "Jetson Jose da Silva (Jetson)",
      "Matrícula": "1396047",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-07-16",
      "Fim": "2025-07-25"
    },
    {
      "Nome": "Jetson Jose da Silva (Jetson)",
      "Matrícula": "1396047",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-06",
      "Fim": "2025-08-06"
    },
    {
      "Nome": "Jetson Jose da Silva (Jetson)",
      "Matrícula": "1396047",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência ?",
      "Início": "2025-10-06",
      "Fim": "2025-10-07"
    },
    {
      "Nome": "Jetson Jose da Silva (Jetson)",
      "Matrícula": "1396047",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-12-08",
      "Fim": "2025-12-08"
    },
    {
      "Nome": "Jetson Jose da Silva (Jetson)",
      "Matrícula": "1396047",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-12-23",
      "Fim": "2026-01-01"
    },
    {
      "Nome": "Jetson Jose da Silva (Jetson)",
      "Matrícula": "1396047",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2026-01-02",
      "Fim": "2026-01-11"
    },
    {
      "Nome": "Joao Alberto da Silva Tavares Junior (Tavares Junior)",
      "Matrícula": "1540697",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-02-24",
      "Fim": "2025-02-24"
    },
    {
      "Nome": "Joao Alberto da Silva Tavares Junior (Tavares Junior)",
      "Matrícula": "1540697",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-02-28",
      "Fim": "2025-02-28"
    },
    {
      "Nome": "Joao Alberto da Silva Tavares Junior (Tavares Junior)",
      "Matrícula": "1540697",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-03-04",
      "Fim": "2025-03-13"
    },
    {
      "Nome": "Joao Alberto da Silva Tavares Junior (Tavares Junior)",
      "Matrícula": "1540697",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-03-16",
      "Fim": "2025-03-16"
    },
    {
      "Nome": "Joao Alberto da Silva Tavares Junior (Tavares Junior)",
      "Matrícula": "1540697",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-03-20",
      "Fim": "2025-03-20"
    },
    {
      "Nome": "Joao Alberto da Silva Tavares Junior (Tavares Junior)",
      "Matrícula": "1540697",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-04-05",
      "Fim": "2025-04-05"
    },
    {
      "Nome": "Joao Alberto da Silva Tavares Junior (Tavares Junior)",
      "Matrícula": "1540697",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-04-29",
      "Fim": "2025-05-01"
    },
    {
      "Nome": "Joao Alberto da Silva Tavares Junior (Tavares Junior)",
      "Matrícula": "1540697",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-23",
      "Fim": "2025-05-23"
    },
    {
      "Nome": "Joao Alberto da Silva Tavares Junior (Tavares Junior)",
      "Matrícula": "1540697",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-12",
      "Fim": "2025-06-12"
    },
    {
      "Nome": "Joao Alberto da Silva Tavares Junior (Tavares Junior)",
      "Matrícula": "1540697",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-06-19",
      "Fim": "2025-06-28"
    },
    {
      "Nome": "Joao Alberto da Silva Tavares Junior (Tavares Junior)",
      "Matrícula": "1540697",
      "Lotação": "NPF/DEL03-DF",
      "Código": "81",
      "Sigla": "LICCPACITA",
      "Descrição": "Lic. Capacitação - EST NÃO Permite Frequência ?",
      "Início": "2025-07-01",
      "Fim": "2025-09-28"
    },
    {
      "Nome": "Joao Alberto da Silva Tavares Junior (Tavares Junior)",
      "Matrícula": "1540697",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-11-21",
      "Fim": "2025-11-22"
    },
    {
      "Nome": "Joao Alberto da Silva Tavares Junior (Tavares Junior)",
      "Matrícula": "1540697",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-11-25",
      "Fim": "2025-11-25"
    },
    {
      "Nome": "Joao Alberto da Silva Tavares Junior (Tavares Junior)",
      "Matrícula": "1540697",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-12-17",
      "Fim": "2026-01-05"
    },
    {
      "Nome": "Joao Alberto da Silva Tavares Junior (Tavares Junior)",
      "Matrícula": "1540697",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2026-01-06",
      "Fim": "2026-01-15"
    },
    {
      "Nome": "Jonas Felipe dos Santos Lima (Jonas Felipe)",
      "Matrícula": "2263379",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2024-12-05",
      "Fim": "2025-01-18"
    },
    {
      "Nome": "Jonas Felipe dos Santos Lima (Jonas Felipe)",
      "Matrícula": "2263379",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-01-29",
      "Fim": "2025-02-07"
    },
    {
      "Nome": "Jonas Felipe dos Santos Lima (Jonas Felipe)",
      "Matrícula": "2263379",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-02-22",
      "Fim": "2025-02-24"
    },
    {
      "Nome": "Jonas Felipe dos Santos Lima (Jonas Felipe)",
      "Matrícula": "2263379",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-03-28",
      "Fim": "2025-04-06"
    },
    {
      "Nome": "Jonas Felipe dos Santos Lima (Jonas Felipe)",
      "Matrícula": "2263379",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-04-26",
      "Fim": "2025-04-26"
    },
    {
      "Nome": "Jonas Felipe dos Santos Lima (Jonas Felipe)",
      "Matrícula": "2263379",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-04",
      "Fim": "2025-05-04"
    },
    {
      "Nome": "Jonas Felipe dos Santos Lima (Jonas Felipe)",
      "Matrícula": "2263379",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-05-09",
      "Fim": "2025-05-18"
    },
    {
      "Nome": "Jonas Felipe dos Santos Lima (Jonas Felipe)",
      "Matrícula": "2263379",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-04",
      "Fim": "2025-08-04"
    },
    {
      "Nome": "Jonas Felipe dos Santos Lima (Jonas Felipe)",
      "Matrícula": "2263379",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-09-13",
      "Fim": "2025-09-13"
    },
    {
      "Nome": "Jonas Felipe dos Santos Lima (Jonas Felipe)",
      "Matrícula": "2263379",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-09-29",
      "Fim": "2025-09-29"
    },
    {
      "Nome": "Jonas Felipe dos Santos Lima (Jonas Felipe)",
      "Matrícula": "2263379",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-15",
      "Fim": "2025-10-15"
    },
    {
      "Nome": "Jonas Felipe dos Santos Lima (Jonas Felipe)",
      "Matrícula": "2263379",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-10-18",
      "Fim": "2025-10-27"
    },
    {
      "Nome": "Jonas Felipe dos Santos Lima (Jonas Felipe)",
      "Matrícula": "2263379",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2026-01-07",
      "Fim": "2026-01-07"
    },
    {
      "Nome": "Jose Gomes Henriques Neto (Henriques Neto)",
      "Matrícula": "1970482",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência",
      "Início": "2025-01-27",
      "Fim": "2025-01-28"
    },
    {
      "Nome": "Jose Gomes Henriques Neto (Henriques Neto)",
      "Matrícula": "1970482",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-02-28",
      "Fim": "2025-02-28"
    },
    {
      "Nome": "Jose Gomes Henriques Neto (Henriques Neto)",
      "Matrícula": "1970482",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-03-16",
      "Fim": "2025-03-16"
    },
    {
      "Nome": "Jose Gomes Henriques Neto (Henriques Neto)",
      "Matrícula": "1970482",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência",
      "Início": "2025-04-05",
      "Fim": "2025-04-06"
    },
    {
      "Nome": "Jose Gomes Henriques Neto (Henriques Neto)",
      "Matrícula": "1970482",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-04-11",
      "Fim": "2025-04-23"
    },
    {
      "Nome": "Jose Gomes Henriques Neto (Henriques Neto)",
      "Matrícula": "1970482",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-07",
      "Fim": "2025-05-07"
    },
    {
      "Nome": "Jose Gomes Henriques Neto (Henriques Neto)",
      "Matrícula": "1970482",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-31",
      "Fim": "2025-05-31"
    },
    {
      "Nome": "Jose Gomes Henriques Neto (Henriques Neto)",
      "Matrícula": "1970482",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-06-01",
      "Fim": "2025-06-20"
    },
    {
      "Nome": "Jose Gomes Henriques Neto (Henriques Neto)",
      "Matrícula": "1970482",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-24",
      "Fim": "2025-06-24"
    },
    {
      "Nome": "Jose Gomes Henriques Neto (Henriques Neto)",
      "Matrícula": "1970482",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-03",
      "Fim": "2025-08-03"
    },
    {
      "Nome": "Jose Gomes Henriques Neto (Henriques Neto)",
      "Matrícula": "1970482",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-15",
      "Fim": "2025-08-15"
    },
    {
      "Nome": "Jose Gomes Henriques Neto (Henriques Neto)",
      "Matrícula": "1970482",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-09-28",
      "Fim": "2025-09-28"
    },
    {
      "Nome": "Jose Gomes Henriques Neto (Henriques Neto)",
      "Matrícula": "1970482",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-18",
      "Fim": "2025-10-18"
    },
    {
      "Nome": "Jose Gomes Henriques Neto (Henriques Neto)",
      "Matrícula": "1970482",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-10-21",
      "Fim": "2025-10-30"
    },
    {
      "Nome": "Jose Gomes Henriques Neto (Henriques Neto)",
      "Matrícula": "1970482",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência ?",
      "Início": "2025-11-05",
      "Fim": "2025-11-25"
    },
    {
      "Nome": "Jose Gomes Henriques Neto (Henriques Neto)",
      "Matrícula": "1970482",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-11-23",
      "Fim": "2025-11-23"
    },
    {
      "Nome": "Jose Gomes Henriques Neto (Henriques Neto)",
      "Matrícula": "1970482",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2026-01-02",
      "Fim": "2026-01-04"
    },
    {
      "Nome": "Judivan da Silva Lopes (Judivan)",
      "Matrícula": "1310518",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-01-20",
      "Fim": "2025-01-20"
    },
    {
      "Nome": "Judivan da Silva Lopes (Judivan)",
      "Matrícula": "1310518",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-01-28",
      "Fim": "2025-01-28"
    },
    {
      "Nome": "Judivan da Silva Lopes (Judivan)",
      "Matrícula": "1310518",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-02-13",
      "Fim": "2025-02-13"
    },
    {
      "Nome": "Judivan da Silva Lopes (Judivan)",
      "Matrícula": "1310518",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-03-01",
      "Fim": "2025-03-05"
    },
    {
      "Nome": "Judivan da Silva Lopes (Judivan)",
      "Matrícula": "1310518",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-04-06",
      "Fim": "2025-04-06"
    },
    {
      "Nome": "Judivan da Silva Lopes (Judivan)",
      "Matrícula": "1310518",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-04-22",
      "Fim": "2025-04-22"
    },
    {
      "Nome": "Judivan da Silva Lopes (Judivan)",
      "Matrícula": "1310518",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-06-01",
      "Fim": "2025-06-02"
    },
    {
      "Nome": "Judivan da Silva Lopes (Judivan)",
      "Matrícula": "1310518",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-13",
      "Fim": "2025-06-13"
    },
    {
      "Nome": "Judivan da Silva Lopes (Judivan)",
      "Matrícula": "1310518",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-25",
      "Fim": "2025-06-25"
    },
    {
      "Nome": "Judivan da Silva Lopes (Judivan)",
      "Matrícula": "1310518",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-07-11",
      "Fim": "2025-07-20"
    },
    {
      "Nome": "Judivan da Silva Lopes (Judivan)",
      "Matrícula": "1310518",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-07-23",
      "Fim": "2025-07-23"
    },
    {
      "Nome": "Judivan da Silva Lopes (Judivan)",
      "Matrícula": "1310518",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-07-31",
      "Fim": "2025-07-31"
    },
    {
      "Nome": "Judivan da Silva Lopes (Judivan)",
      "Matrícula": "1310518",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-16",
      "Fim": "2025-08-16"
    },
    {
      "Nome": "Judivan da Silva Lopes (Judivan)",
      "Matrícula": "1310518",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-09-17",
      "Fim": "2025-09-17"
    },
    {
      "Nome": "Judivan da Silva Lopes (Judivan)",
      "Matrícula": "1310518",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência ?",
      "Início": "2025-10-21",
      "Fim": "2025-11-24"
    },
    {
      "Nome": "Judivan da Silva Lopes (Judivan)",
      "Matrícula": "1310518",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-12-02",
      "Fim": "2025-12-02"
    },
    {
      "Nome": "Judivan da Silva Lopes (Judivan)",
      "Matrícula": "1310518",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-12-10",
      "Fim": "2025-12-10"
    },
    {
      "Nome": "Judivan da Silva Lopes (Judivan)",
      "Matrícula": "1310518",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-12-17",
      "Fim": "2025-12-31"
    },
    {
      "Nome": "Juliana Batista Silva Moreira (Juliana Moreira)",
      "Matrícula": "1880115",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-02-06",
      "Fim": "2025-02-06"
    },
    {
      "Nome": "Juliana Batista Silva Moreira (Juliana Moreira)",
      "Matrícula": "1880115",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-02-22",
      "Fim": "2025-02-22"
    },
    {
      "Nome": "Juliana Batista Silva Moreira (Juliana Moreira)",
      "Matrícula": "1880115",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-03-30",
      "Fim": "2025-03-30"
    },
    {
      "Nome": "Juliana Batista Silva Moreira (Juliana Moreira)",
      "Matrícula": "1880115",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-04-15",
      "Fim": "2025-04-29"
    },
    {
      "Nome": "Juliana Batista Silva Moreira (Juliana Moreira)",
      "Matrícula": "1880115",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência",
      "Início": "2025-05-01",
      "Fim": "2025-05-01"
    },
    {
      "Nome": "Juliana Batista Silva Moreira (Juliana Moreira)",
      "Matrícula": "1880115",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-29",
      "Fim": "2025-05-29"
    },
    {
      "Nome": "Juliana Batista Silva Moreira (Juliana Moreira)",
      "Matrícula": "1880115",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-06",
      "Fim": "2025-06-06"
    },
    {
      "Nome": "Juliana Batista Silva Moreira (Juliana Moreira)",
      "Matrícula": "1880115",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-14",
      "Fim": "2025-06-14"
    },
    {
      "Nome": "Juliana Batista Silva Moreira (Juliana Moreira)",
      "Matrícula": "1880115",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência ?",
      "Início": "2025-06-28",
      "Fim": "2025-07-11"
    },
    {
      "Nome": "Juliana Batista Silva Moreira (Juliana Moreira)",
      "Matrícula": "1880115",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-09",
      "Fim": "2025-08-09"
    },
    {
      "Nome": "Juliana Batista Silva Moreira (Juliana Moreira)",
      "Matrícula": "1880115",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-21",
      "Fim": "2025-08-21"
    },
    {
      "Nome": "Juliana Batista Silva Moreira (Juliana Moreira)",
      "Matrícula": "1880115",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-25",
      "Fim": "2025-08-25"
    },
    {
      "Nome": "Juliana Batista Silva Moreira (Juliana Moreira)",
      "Matrícula": "1880115",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-09-14",
      "Fim": "2025-09-14"
    },
    {
      "Nome": "Juliana Batista Silva Moreira (Juliana Moreira)",
      "Matrícula": "1880115",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência ?",
      "Início": "2025-09-22",
      "Fim": "2025-10-22"
    },
    {
      "Nome": "Juliana Batista Silva Moreira (Juliana Moreira)",
      "Matrícula": "1880115",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-09-22",
      "Fim": "2025-09-22"
    },
    {
      "Nome": "Juliana Batista Silva Moreira (Juliana Moreira)",
      "Matrícula": "1880115",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-28",
      "Fim": "2025-10-28"
    },
    {
      "Nome": "Juliana Batista Silva Moreira (Juliana Moreira)",
      "Matrícula": "1880115",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-11-09",
      "Fim": "2025-11-09"
    },
    {
      "Nome": "Juliana Batista Silva Moreira (Juliana Moreira)",
      "Matrícula": "1880115",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-11-13",
      "Fim": "2025-11-13"
    },
    {
      "Nome": "Juliana Batista Silva Moreira (Juliana Moreira)",
      "Matrícula": "1880115",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-12-15",
      "Fim": "2025-12-15"
    },
    {
      "Nome": "Juliana Batista Silva Moreira (Juliana Moreira)",
      "Matrícula": "1880115",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-12-17",
      "Fim": "2025-12-31"
    },
    {
      "Nome": "Leandro Regis Portes Crizostimo (Leandro Regis)",
      "Matrícula": "2194999",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência",
      "Início": "2025-01-19",
      "Fim": "2025-01-20"
    },
    {
      "Nome": "Leandro Regis Portes Crizostimo (Leandro Regis)",
      "Matrícula": "2194999",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-01-31",
      "Fim": "2025-02-09"
    },
    {
      "Nome": "Leandro Regis Portes Crizostimo (Leandro Regis)",
      "Matrícula": "2194999",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-02-12",
      "Fim": "2025-02-12"
    },
    {
      "Nome": "Leandro Regis Portes Crizostimo (Leandro Regis)",
      "Matrícula": "2194999",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência",
      "Início": "2025-02-20",
      "Fim": "2025-02-21"
    },
    {
      "Nome": "Leandro Regis Portes Crizostimo (Leandro Regis)",
      "Matrícula": "2194999",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-03-04",
      "Fim": "2025-03-04"
    },
    {
      "Nome": "Leandro Regis Portes Crizostimo (Leandro Regis)",
      "Matrícula": "2194999",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-04-01",
      "Fim": "2025-04-01"
    },
    {
      "Nome": "Leandro Regis Portes Crizostimo (Leandro Regis)",
      "Matrícula": "2194999",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-04-04",
      "Fim": "2025-04-13"
    },
    {
      "Nome": "Leandro Regis Portes Crizostimo (Leandro Regis)",
      "Matrícula": "2194999",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-19",
      "Fim": "2025-05-19"
    },
    {
      "Nome": "Leandro Regis Portes Crizostimo (Leandro Regis)",
      "Matrícula": "2194999",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-12",
      "Fim": "2025-06-12"
    },
    {
      "Nome": "Leandro Regis Portes Crizostimo (Leandro Regis)",
      "Matrícula": "2194999",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-07-06",
      "Fim": "2025-07-06"
    },
    {
      "Nome": "Leandro Regis Portes Crizostimo (Leandro Regis)",
      "Matrícula": "2194999",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-07",
      "Fim": "2025-08-07"
    },
    {
      "Nome": "Leandro Regis Portes Crizostimo (Leandro Regis)",
      "Matrícula": "2194999",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-08-11",
      "Fim": "2025-08-20"
    },
    {
      "Nome": "Leandro Regis Portes Crizostimo (Leandro Regis)",
      "Matrícula": "2194999",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência ?",
      "Início": "2025-10-06",
      "Fim": "2025-10-07"
    },
    {
      "Nome": "Leandro Regis Portes Crizostimo (Leandro Regis)",
      "Matrícula": "2194999",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-10-14",
      "Fim": "2025-10-23"
    },
    {
      "Nome": "Leandro Regis Portes Crizostimo (Leandro Regis)",
      "Matrícula": "2194999",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-11-28",
      "Fim": "2025-11-28"
    },
    {
      "Nome": "Leandro Regis Portes Crizostimo (Leandro Regis)",
      "Matrícula": "2194999",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-12-12",
      "Fim": "2025-12-12"
    },
    {
      "Nome": "Lenilson Martins de Oliveira (Lenilson)",
      "Matrícula": "1201020",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-03-25",
      "Fim": "2025-04-08"
    },
    {
      "Nome": "Lenilson Martins de Oliveira (Lenilson)",
      "Matrícula": "1201020",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-04-09",
      "Fim": "2025-05-08"
    },
    {
      "Nome": "Lenilson Martins de Oliveira (Lenilson)",
      "Matrícula": "1201020",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-05-07",
      "Fim": "2025-08-04"
    },
    {
      "Nome": "Lenilson Martins de Oliveira (Lenilson)",
      "Matrícula": "1201020",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-08-05",
      "Fim": "2025-11-02"
    },
    {
      "Nome": "Lenilson Martins de Oliveira (Lenilson)",
      "Matrícula": "1201020",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-10-29",
      "Fim": "2025-12-27"
    },
    {
      "Nome": "Leonardo Silva da Costa Gomes (Costa Gomes)",
      "Matrícula": "3269685",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-10",
      "Fim": "2025-05-10"
    },
    {
      "Nome": "Leonardo Silva da Costa Gomes (Costa Gomes)",
      "Matrícula": "3269685",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-15",
      "Fim": "2025-05-15"
    },
    {
      "Nome": "Leonardo Silva da Costa Gomes (Costa Gomes)",
      "Matrícula": "3269685",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-06-04",
      "Fim": "2025-07-03"
    },
    {
      "Nome": "Leonardo Silva da Costa Gomes (Costa Gomes)",
      "Matrícula": "3269685",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-07-04",
      "Fim": "2025-09-01"
    },
    {
      "Nome": "Leonardo Silva da Costa Gomes (Costa Gomes)",
      "Matrícula": "3269685",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-09-02",
      "Fim": "2025-10-31"
    },
    {
      "Nome": "Leonardo Silva da Costa Gomes (Costa Gomes)",
      "Matrícula": "3269685",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-11-03",
      "Fim": "2026-01-01"
    },
    {
      "Nome": "Lucas Barros Torres de Oliveira (Lucas Barros)",
      "Matrícula": "3211233",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-01-01",
      "Fim": "2025-01-10"
    },
    {
      "Nome": "Lucas Barros Torres de Oliveira (Lucas Barros)",
      "Matrícula": "3211233",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-01-30",
      "Fim": "2025-02-01"
    },
    {
      "Nome": "Lucas Barros Torres de Oliveira (Lucas Barros)",
      "Matrícula": "3211233",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-02-08",
      "Fim": "2025-02-08"
    },
    {
      "Nome": "Lucas Barros Torres de Oliveira (Lucas Barros)",
      "Matrícula": "3211233",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-02-28",
      "Fim": "2025-03-09"
    },
    {
      "Nome": "Lucas Barros Torres de Oliveira (Lucas Barros)",
      "Matrícula": "3211233",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-03-10",
      "Fim": "2025-05-08"
    },
    {
      "Nome": "Lucas Barros Torres de Oliveira (Lucas Barros)",
      "Matrícula": "3211233",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-03-16",
      "Fim": "2025-03-16"
    },
    {
      "Nome": "Lucas Barros Torres de Oliveira (Lucas Barros)",
      "Matrícula": "3211233",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-05-08",
      "Fim": "2025-07-06"
    },
    {
      "Nome": "Lucas Barros Torres de Oliveira (Lucas Barros)",
      "Matrícula": "3211233",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-07-04",
      "Fim": "2025-09-01"
    },
    {
      "Nome": "Lucas Barros Torres de Oliveira (Lucas Barros)",
      "Matrícula": "3211233",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-09-02",
      "Fim": "2025-09-11"
    },
    {
      "Nome": "Lucas Barros Torres de Oliveira (Lucas Barros)",
      "Matrícula": "3211233",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-05",
      "Fim": "2025-10-05"
    },
    {
      "Nome": "Lucas Barros Torres de Oliveira (Lucas Barros)",
      "Matrícula": "3211233",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-10-09",
      "Fim": "2025-10-18"
    },
    {
      "Nome": "Lucas Barros Torres de Oliveira (Lucas Barros)",
      "Matrícula": "3211233",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-11-18",
      "Fim": "2025-11-18"
    },
    {
      "Nome": "Lucas Barros Torres de Oliveira (Lucas Barros)",
      "Matrícula": "3211233",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-11-21",
      "Fim": "2025-11-23"
    },
    {
      "Nome": "Lucas Barros Torres de Oliveira (Lucas Barros)",
      "Matrícula": "3211233",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-11-30",
      "Fim": "2025-11-30"
    },
    {
      "Nome": "Lucas Campos Dantas (Lucas Campos)",
      "Matrícula": "2150637",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-02-01",
      "Fim": "2025-02-10"
    },
    {
      "Nome": "Lucas Campos Dantas (Lucas Campos)",
      "Matrícula": "2150637",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-04-20",
      "Fim": "2025-04-20"
    },
    {
      "Nome": "Lucas Campos Dantas (Lucas Campos)",
      "Matrícula": "2150637",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-06",
      "Fim": "2025-05-06"
    },
    {
      "Nome": "Lucas Campos Dantas (Lucas Campos)",
      "Matrícula": "2150637",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-18",
      "Fim": "2025-05-18"
    },
    {
      "Nome": "Lucas Campos Dantas (Lucas Campos)",
      "Matrícula": "2150637",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-11",
      "Fim": "2025-06-11"
    },
    {
      "Nome": "Lucas Campos Dantas (Lucas Campos)",
      "Matrícula": "2150637",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-15",
      "Fim": "2025-06-15"
    },
    {
      "Nome": "Lucas Campos Dantas (Lucas Campos)",
      "Matrícula": "2150637",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-06-19",
      "Fim": "2025-06-23"
    },
    {
      "Nome": "Lucas Campos Dantas (Lucas Campos)",
      "Matrícula": "2150637",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-07-01",
      "Fim": "2025-07-02"
    },
    {
      "Nome": "Lucas Campos Dantas (Lucas Campos)",
      "Matrícula": "2150637",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-07-16",
      "Fim": "2025-07-18"
    },
    {
      "Nome": "Lucas Campos Dantas (Lucas Campos)",
      "Matrícula": "2150637",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-02",
      "Fim": "2025-08-02"
    },
    {
      "Nome": "Lucas Campos Dantas (Lucas Campos)",
      "Matrícula": "2150637",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-06",
      "Fim": "2025-08-06"
    },
    {
      "Nome": "Lucas Campos Dantas (Lucas Campos)",
      "Matrícula": "2150637",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-09-11",
      "Fim": "2025-09-11"
    },
    {
      "Nome": "Lucas Campos Dantas (Lucas Campos)",
      "Matrícula": "2150637",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-25",
      "Fim": "2025-10-25"
    },
    {
      "Nome": "Lucas Campos Dantas (Lucas Campos)",
      "Matrícula": "2150637",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-11-30",
      "Fim": "2025-11-30"
    },
    {
      "Nome": "Lucas Campos Dantas (Lucas Campos)",
      "Matrícula": "2150637",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-12-20",
      "Fim": "2026-01-03"
    },
    {
      "Nome": "Luiz Claudio Brito dos Santos (C. Brito)",
      "Matrícula": "1396159",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência",
      "Início": "2025-01-02",
      "Fim": "2025-01-17"
    },
    {
      "Nome": "Luiz Claudio Brito dos Santos (C. Brito)",
      "Matrícula": "1396159",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência",
      "Início": "2025-01-26",
      "Fim": "2025-01-27"
    },
    {
      "Nome": "Luiz Claudio Brito dos Santos (C. Brito)",
      "Matrícula": "1396159",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-02-07",
      "Fim": "2025-02-07"
    },
    {
      "Nome": "Luiz Claudio Brito dos Santos (C. Brito)",
      "Matrícula": "1396159",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-02-11",
      "Fim": "2025-02-11"
    },
    {
      "Nome": "Luiz Claudio Brito dos Santos (C. Brito)",
      "Matrícula": "1396159",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-03-23",
      "Fim": "2025-03-23"
    },
    {
      "Nome": "Luiz Claudio Brito dos Santos (C. Brito)",
      "Matrícula": "1396159",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-03-26",
      "Fim": "2025-04-08"
    },
    {
      "Nome": "Luiz Claudio Brito dos Santos (C. Brito)",
      "Matrícula": "1396159",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-04-12",
      "Fim": "2025-04-12"
    },
    {
      "Nome": "Luiz Claudio Brito dos Santos (C. Brito)",
      "Matrícula": "1396159",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-10",
      "Fim": "2025-05-10"
    },
    {
      "Nome": "Luiz Claudio Brito dos Santos (C. Brito)",
      "Matrícula": "1396159",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-15",
      "Fim": "2025-06-15"
    },
    {
      "Nome": "Luiz Claudio Brito dos Santos (C. Brito)",
      "Matrícula": "1396159",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência ?",
      "Início": "2025-06-21",
      "Fim": "2025-07-11"
    },
    {
      "Nome": "Luiz Claudio Brito dos Santos (C. Brito)",
      "Matrícula": "1396159",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-07-21",
      "Fim": "2025-07-21"
    },
    {
      "Nome": "Luiz Claudio Brito dos Santos (C. Brito)",
      "Matrícula": "1396159",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-14",
      "Fim": "2025-08-14"
    },
    {
      "Nome": "Luiz Claudio Brito dos Santos (C. Brito)",
      "Matrícula": "1396159",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-18",
      "Fim": "2025-08-18"
    },
    {
      "Nome": "Luiz Claudio Brito dos Santos (C. Brito)",
      "Matrícula": "1396159",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-26",
      "Fim": "2025-08-26"
    },
    {
      "Nome": "Luiz Claudio Brito dos Santos (C. Brito)",
      "Matrícula": "1396159",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-09-03",
      "Fim": "2025-09-03"
    },
    {
      "Nome": "Luiz Claudio Brito dos Santos (C. Brito)",
      "Matrícula": "1396159",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-09-07",
      "Fim": "2025-09-21"
    },
    {
      "Nome": "Luiz Claudio Brito dos Santos (C. Brito)",
      "Matrícula": "1396159",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-09",
      "Fim": "2025-10-09"
    },
    {
      "Nome": "Luiz Claudio Brito dos Santos (C. Brito)",
      "Matrícula": "1396159",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-21",
      "Fim": "2025-10-21"
    },
    {
      "Nome": "Luiz Claudio Brito dos Santos (C. Brito)",
      "Matrícula": "1396159",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-11-22",
      "Fim": "2025-11-22"
    },
    {
      "Nome": "Marcello Carvalhedo Kovalski (M. Kovalski)",
      "Matrícula": "3158960",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-02-04",
      "Fim": "2025-02-04"
    },
    {
      "Nome": "Marcello Carvalhedo Kovalski (M. Kovalski)",
      "Matrícula": "3158960",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-04-04",
      "Fim": "2025-04-06"
    },
    {
      "Nome": "Marcello Carvalhedo Kovalski (M. Kovalski)",
      "Matrícula": "3158960",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-04-07",
      "Fim": "2025-04-18"
    },
    {
      "Nome": "Marcello Carvalhedo Kovalski (M. Kovalski)",
      "Matrícula": "3158960",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência ?",
      "Início": "2025-06-23",
      "Fim": "2025-07-14"
    },
    {
      "Nome": "Marcello Carvalhedo Kovalski (M. Kovalski)",
      "Matrícula": "3158960",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência",
      "Início": "2025-07-15",
      "Fim": "2025-07-18"
    },
    {
      "Nome": "Marcello Carvalhedo Kovalski (M. Kovalski)",
      "Matrícula": "3158960",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-07-21",
      "Fim": "2025-08-06"
    },
    {
      "Nome": "Marcello Carvalhedo Kovalski (M. Kovalski)",
      "Matrícula": "3158960",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-09-28",
      "Fim": "2025-09-28"
    },
    {
      "Nome": "Marcello Carvalhedo Kovalski (M. Kovalski)",
      "Matrícula": "3158960",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-10-06",
      "Fim": "2025-10-10"
    },
    {
      "Nome": "Marcio Barbosa Nogueira (M. Nogueira)",
      "Matrícula": "1166632",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2024-12-24",
      "Fim": "2025-01-22"
    },
    {
      "Nome": "Marcio Barbosa Nogueira (M. Nogueira)",
      "Matrícula": "1166632",
      "Lotação": "NPF/DEL03-DF",
      "Código": "90",
      "Sigla": "LICMDPEFAM",
      "Descrição": "Lic. por Motivo de Doença em Pesssoa da Família - EST NÃO Permite Frequência",
      "Início": "2025-02-05",
      "Fim": "2025-02-06"
    },
    {
      "Nome": "Marcio Barbosa Nogueira (M. Nogueira)",
      "Matrícula": "1166632",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-02-14",
      "Fim": "2025-02-23"
    },
    {
      "Nome": "Marcio Barbosa Nogueira (M. Nogueira)",
      "Matrícula": "1166632",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-02-24",
      "Fim": "2025-03-03"
    },
    {
      "Nome": "Marcio Barbosa Nogueira (M. Nogueira)",
      "Matrícula": "1166632",
      "Lotação": "NPF/DEL03-DF",
      "Código": "90",
      "Sigla": "LICMDPEFAM",
      "Descrição": "Lic. por Motivo de Doença em Pesssoa da Família - EST NÃO Permite Frequência",
      "Início": "2025-04-16",
      "Fim": "2025-04-16"
    },
    {
      "Nome": "Marcio Barbosa Nogueira (M. Nogueira)",
      "Matrícula": "1166632",
      "Lotação": "NPF/DEL03-DF",
      "Código": "90",
      "Sigla": "LICMDPEFAM",
      "Descrição": "Lic. por Motivo de Doença em Pesssoa da Família - EST NÃO Permite Frequência",
      "Início": "2025-04-19",
      "Fim": "2025-04-25"
    },
    {
      "Nome": "Marcio Barbosa Nogueira (M. Nogueira)",
      "Matrícula": "1166632",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-04-28",
      "Fim": "2025-04-28"
    },
    {
      "Nome": "Marcio Barbosa Nogueira (M. Nogueira)",
      "Matrícula": "1166632",
      "Lotação": "NPF/DEL03-DF",
      "Código": "90",
      "Sigla": "LICMDPEFAM",
      "Descrição": "Lic. por Motivo de Doença em Pesssoa da Família - EST NÃO Permite Frequência",
      "Início": "2025-06-05",
      "Fim": "2025-07-04"
    },
    {
      "Nome": "Marcio Barbosa Nogueira (M. Nogueira)",
      "Matrícula": "1166632",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-07-18",
      "Fim": "2025-07-20"
    },
    {
      "Nome": "Marcio Barbosa Nogueira (M. Nogueira)",
      "Matrícula": "1166632",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-08-01",
      "Fim": "2025-08-10"
    },
    {
      "Nome": "Marcio Barbosa Nogueira (M. Nogueira)",
      "Matrícula": "1166632",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-22",
      "Fim": "2025-08-22"
    },
    {
      "Nome": "Marcio Barbosa Nogueira (M. Nogueira)",
      "Matrícula": "1166632",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-09-03",
      "Fim": "2025-09-03"
    },
    {
      "Nome": "Marcio Barbosa Nogueira (M. Nogueira)",
      "Matrícula": "1166632",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência",
      "Início": "2025-09-30",
      "Fim": "2025-10-03"
    },
    {
      "Nome": "Marcio Barbosa Nogueira (M. Nogueira)",
      "Matrícula": "1166632",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-10-06",
      "Fim": "2025-10-15"
    },
    {
      "Nome": "Marcio Barbosa Nogueira (M. Nogueira)",
      "Matrícula": "1166632",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-21",
      "Fim": "2025-10-21"
    },
    {
      "Nome": "Marcio Barbosa Nogueira (M. Nogueira)",
      "Matrícula": "1166632",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-10-29",
      "Fim": "2025-10-30"
    },
    {
      "Nome": "Marcio Barbosa Nogueira (M. Nogueira)",
      "Matrícula": "1166632",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-11-10",
      "Fim": "2025-11-10"
    },
    {
      "Nome": "Marcio Barbosa Nogueira (M. Nogueira)",
      "Matrícula": "1166632",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-11-14",
      "Fim": "2025-11-14"
    },
    {
      "Nome": "Marcio Barbosa Nogueira (M. Nogueira)",
      "Matrícula": "1166632",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2026-01-01",
      "Fim": "2026-01-10"
    },
    {
      "Nome": "Marcio de Araujo Matos (Marcio Araujo)",
      "Matrícula": "1461390",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-01-05",
      "Fim": "2025-01-13"
    },
    {
      "Nome": "Marcio de Araujo Matos (Marcio Araujo)",
      "Matrícula": "1461390",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-01-23",
      "Fim": "2025-01-26"
    },
    {
      "Nome": "Marcio de Araujo Matos (Marcio Araujo)",
      "Matrícula": "1461390",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-02-05",
      "Fim": "2025-02-11"
    },
    {
      "Nome": "Marcio de Araujo Matos (Marcio Araujo)",
      "Matrícula": "1461390",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-01",
      "Fim": "2025-05-01"
    },
    {
      "Nome": "Marcio de Araujo Matos (Marcio Araujo)",
      "Matrícula": "1461390",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-05",
      "Fim": "2025-05-05"
    },
    {
      "Nome": "Marcio de Araujo Matos (Marcio Araujo)",
      "Matrícula": "1461390",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-25",
      "Fim": "2025-05-25"
    },
    {
      "Nome": "Marcio de Araujo Matos (Marcio Araujo)",
      "Matrícula": "1461390",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-06-01",
      "Fim": "2025-06-03"
    },
    {
      "Nome": "Marcio de Araujo Matos (Marcio Araujo)",
      "Matrícula": "1461390",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-06-04",
      "Fim": "2025-06-10"
    },
    {
      "Nome": "Marcio de Araujo Matos (Marcio Araujo)",
      "Matrícula": "1461390",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-07-11",
      "Fim": "2025-07-25"
    },
    {
      "Nome": "Marcio de Araujo Matos (Marcio Araujo)",
      "Matrícula": "1461390",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-07-12",
      "Fim": "2025-07-12"
    },
    {
      "Nome": "Marcio de Araujo Matos (Marcio Araujo)",
      "Matrícula": "1461390",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-07-25",
      "Fim": "2025-08-08"
    },
    {
      "Nome": "Marcio de Araujo Matos (Marcio Araujo)",
      "Matrícula": "1461390",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-08-09",
      "Fim": "2025-08-17"
    },
    {
      "Nome": "Marcio de Araujo Matos (Marcio Araujo)",
      "Matrícula": "1461390",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-21",
      "Fim": "2025-08-21"
    },
    {
      "Nome": "Marcio de Araujo Matos (Marcio Araujo)",
      "Matrícula": "1461390",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-25",
      "Fim": "2025-08-25"
    },
    {
      "Nome": "Marcio de Araujo Matos (Marcio Araujo)",
      "Matrícula": "1461390",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-09-14",
      "Fim": "2025-09-14"
    },
    {
      "Nome": "Marcio de Araujo Matos (Marcio Araujo)",
      "Matrícula": "1461390",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-10-14",
      "Fim": "2025-10-28"
    },
    {
      "Nome": "Marcio de Araujo Matos (Marcio Araujo)",
      "Matrícula": "1461390",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-20",
      "Fim": "2025-10-20"
    },
    {
      "Nome": "Marcio de Araujo Matos (Marcio Araujo)",
      "Matrícula": "1461390",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-11-29",
      "Fim": "2025-11-29"
    },
    {
      "Nome": "Marcio de Araujo Matos (Marcio Araujo)",
      "Matrícula": "1461390",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-12-03",
      "Fim": "2025-12-14"
    },
    {
      "Nome": "Marcio de Araujo Matos (Marcio Araujo)",
      "Matrícula": "1461390",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-12-17",
      "Fim": "2025-12-20"
    },
    {
      "Nome": "Marcio de Araujo Matos (Marcio Araujo)",
      "Matrícula": "1461390",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-12-23",
      "Fim": "2025-12-23"
    },
    {
      "Nome": "Marcio de Araujo Matos (Marcio Araujo)",
      "Matrícula": "1461390",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2026-01-04",
      "Fim": "2026-01-12"
    },
    {
      "Nome": "Mario Seixas Sales (Mário Seixas)",
      "Matrícula": "3158094",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência ?",
      "Início": "2025-01-18",
      "Fim": "2025-02-01"
    },
    {
      "Nome": "Mario Seixas Sales (Mário Seixas)",
      "Matrícula": "3158094",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência ?",
      "Início": "2025-05-31",
      "Fim": "2025-06-03"
    },
    {
      "Nome": "Mario Seixas Sales (Mário Seixas)",
      "Matrícula": "3158094",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência ?",
      "Início": "2025-07-27",
      "Fim": "2025-08-10"
    },
    {
      "Nome": "Mario Seixas Sales (Mário Seixas)",
      "Matrícula": "3158094",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-11-04",
      "Fim": "2025-11-06"
    },
    {
      "Nome": "Mario Seixas Sales (Mário Seixas)",
      "Matrícula": "3158094",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência ?",
      "Início": "2025-12-27",
      "Fim": "2025-12-27"
    },
    {
      "Nome": "Mario Seixas Sales (Mário Seixas)",
      "Matrícula": "3158094",
      "Lotação": "NPF/DEL03-DF",
      "Código": "396",
      "Sigla": "LICCAP25I1",
      "Descrição": "Licença para Capacitação Presencial ou à Distância NÃO Permite Frequência ?",
      "Início": "2026-01-02",
      "Fim": "2026-04-01"
    },
    {
      "Nome": "Mario Seixas Sales (Mário Seixas)",
      "Matrícula": "3158094",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2026-01-06",
      "Fim": "2026-01-06"
    },
    {
      "Nome": "Mayara Liberal Santos (Mayara)",
      "Matrícula": "3263808",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-03-07",
      "Fim": "2025-03-07"
    },
    {
      "Nome": "Mayara Liberal Santos (Mayara)",
      "Matrícula": "3263808",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-03-11",
      "Fim": "2025-03-15"
    },
    {
      "Nome": "Mayara Liberal Santos (Mayara)",
      "Matrícula": "3263808",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-04-04",
      "Fim": "2025-04-04"
    },
    {
      "Nome": "Mayara Liberal Santos (Mayara)",
      "Matrícula": "3263808",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-04-24",
      "Fim": "2025-04-24"
    },
    {
      "Nome": "Mayara Liberal Santos (Mayara)",
      "Matrícula": "3263808",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-10",
      "Fim": "2025-05-10"
    },
    {
      "Nome": "Mayara Liberal Santos (Mayara)",
      "Matrícula": "3263808",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-30",
      "Fim": "2025-05-30"
    },
    {
      "Nome": "Mayara Liberal Santos (Mayara)",
      "Matrícula": "3263808",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-23",
      "Fim": "2025-06-23"
    },
    {
      "Nome": "Mayara Liberal Santos (Mayara)",
      "Matrícula": "3263808",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-07-01",
      "Fim": "2025-07-01"
    },
    {
      "Nome": "Mayara Liberal Santos (Mayara)",
      "Matrícula": "3263808",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-18",
      "Fim": "2025-08-18"
    },
    {
      "Nome": "Mayara Liberal Santos (Mayara)",
      "Matrícula": "3263808",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-22",
      "Fim": "2025-08-22"
    },
    {
      "Nome": "Mayara Liberal Santos (Mayara)",
      "Matrícula": "3263808",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-08-26",
      "Fim": "2025-09-07"
    },
    {
      "Nome": "Mayara Liberal Santos (Mayara)",
      "Matrícula": "3263808",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-09-11",
      "Fim": "2025-09-11"
    },
    {
      "Nome": "Mayara Liberal Santos (Mayara)",
      "Matrícula": "3263808",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-09-18",
      "Fim": "2025-09-20"
    },
    {
      "Nome": "Mayara Liberal Santos (Mayara)",
      "Matrícula": "3263808",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-09-23",
      "Fim": "2025-09-23"
    },
    {
      "Nome": "Mayara Liberal Santos (Mayara)",
      "Matrícula": "3263808",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-10-17",
      "Fim": "2025-10-28"
    },
    {
      "Nome": "Mayara Liberal Santos (Mayara)",
      "Matrícula": "3263808",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-29",
      "Fim": "2025-10-29"
    },
    {
      "Nome": "Mayara Liberal Santos (Mayara)",
      "Matrícula": "3263808",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-11-02",
      "Fim": "2025-11-02"
    },
    {
      "Nome": "Mayara Liberal Santos (Mayara)",
      "Matrícula": "3263808",
      "Lotação": "NPF/DEL03-DF",
      "Código": "339",
      "Sigla": "LICTRATSDJ",
      "Descrição": "Lic. Tratam. Saúde (Por Decisão Judicial) - EST NÃO Permite Frequência",
      "Início": "2025-12-11",
      "Fim": "2025-12-13"
    },
    {
      "Nome": "Moacir Negreiros de Moura Junior (Negreiros)",
      "Matrícula": "2150837",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2024-12-24",
      "Fim": "2025-01-06"
    },
    {
      "Nome": "Moacir Negreiros de Moura Junior (Negreiros)",
      "Matrícula": "2150837",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência",
      "Início": "2025-02-21",
      "Fim": "2025-02-23"
    },
    {
      "Nome": "Moacir Negreiros de Moura Junior (Negreiros)",
      "Matrícula": "2150837",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-03-10",
      "Fim": "2025-03-19"
    },
    {
      "Nome": "Moacir Negreiros de Moura Junior (Negreiros)",
      "Matrícula": "2150837",
      "Lotação": "NPF/DEL03-DF",
      "Código": "32",
      "Sigla": "AFTRPPTPOL",
      "Descrição": "Afas. Est/Prog.Trein.(Congr-Encon) País C/Ônus Limit - EST NÃO Permite Frequência",
      "Início": "2025-04-28",
      "Fim": "2025-05-03"
    },
    {
      "Nome": "Moacir Negreiros de Moura Junior (Negreiros)",
      "Matrícula": "2150837",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência",
      "Início": "2025-06-05",
      "Fim": "2025-06-07"
    },
    {
      "Nome": "Moacir Negreiros de Moura Junior (Negreiros)",
      "Matrícula": "2150837",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência",
      "Início": "2025-06-30",
      "Fim": "2025-07-07"
    },
    {
      "Nome": "Moacir Negreiros de Moura Junior (Negreiros)",
      "Matrícula": "2150837",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-08-05",
      "Fim": "2025-08-14"
    },
    {
      "Nome": "Moacir Negreiros de Moura Junior (Negreiros)",
      "Matrícula": "2150837",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência ?",
      "Início": "2025-09-25",
      "Fim": "2025-09-25"
    },
    {
      "Nome": "Moacir Negreiros de Moura Junior (Negreiros)",
      "Matrícula": "2150837",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-12-06",
      "Fim": "2025-12-06"
    },
    {
      "Nome": "Moacir Negreiros de Moura Junior (Negreiros)",
      "Matrícula": "2150837",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-12-24",
      "Fim": "2026-01-02"
    },
    {
      "Nome": "Moacir Negreiros de Moura Junior (Negreiros)",
      "Matrícula": "2150837",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2026-01-03",
      "Fim": "2026-01-03"
    },
    {
      "Nome": "Osmar Cardoso Pereira (Osmar Cardoso)",
      "Matrícula": "3163256",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-01-18",
      "Fim": "2025-01-18"
    },
    {
      "Nome": "Osmar Cardoso Pereira (Osmar Cardoso)",
      "Matrícula": "3163256",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-02-11",
      "Fim": "2025-02-11"
    },
    {
      "Nome": "Osmar Cardoso Pereira (Osmar Cardoso)",
      "Matrícula": "3163256",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-02-12",
      "Fim": "2025-02-19"
    },
    {
      "Nome": "Osmar Cardoso Pereira (Osmar Cardoso)",
      "Matrícula": "3163256",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-02-27",
      "Fim": "2025-02-27"
    },
    {
      "Nome": "Osmar Cardoso Pereira (Osmar Cardoso)",
      "Matrícula": "3163256",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-03-23",
      "Fim": "2025-03-23"
    },
    {
      "Nome": "Osmar Cardoso Pereira (Osmar Cardoso)",
      "Matrícula": "3163256",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-04-12",
      "Fim": "2025-04-12"
    },
    {
      "Nome": "Osmar Cardoso Pereira (Osmar Cardoso)",
      "Matrícula": "3163256",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-04-22",
      "Fim": "2025-04-29"
    },
    {
      "Nome": "Osmar Cardoso Pereira (Osmar Cardoso)",
      "Matrícula": "3163256",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-02",
      "Fim": "2025-05-02"
    },
    {
      "Nome": "Osmar Cardoso Pereira (Osmar Cardoso)",
      "Matrícula": "3163256",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-14",
      "Fim": "2025-05-14"
    },
    {
      "Nome": "Osmar Cardoso Pereira (Osmar Cardoso)",
      "Matrícula": "3163256",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-22",
      "Fim": "2025-05-22"
    },
    {
      "Nome": "Osmar Cardoso Pereira (Osmar Cardoso)",
      "Matrícula": "3163256",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-26",
      "Fim": "2025-05-26"
    },
    {
      "Nome": "Osmar Cardoso Pereira (Osmar Cardoso)",
      "Matrícula": "3163256",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-06-15",
      "Fim": "2025-06-16"
    },
    {
      "Nome": "Osmar Cardoso Pereira (Osmar Cardoso)",
      "Matrícula": "3163256",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-27",
      "Fim": "2025-06-27"
    },
    {
      "Nome": "Osmar Cardoso Pereira (Osmar Cardoso)",
      "Matrícula": "3163256",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-07-03",
      "Fim": "2025-07-14"
    },
    {
      "Nome": "Osmar Cardoso Pereira (Osmar Cardoso)",
      "Matrícula": "3163256",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-07-29",
      "Fim": "2025-07-29"
    },
    {
      "Nome": "Osmar Cardoso Pereira (Osmar Cardoso)",
      "Matrícula": "3163256",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-10",
      "Fim": "2025-08-10"
    },
    {
      "Nome": "Osmar Cardoso Pereira (Osmar Cardoso)",
      "Matrícula": "3163256",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-08-19",
      "Fim": "2025-08-22"
    },
    {
      "Nome": "Osmar Cardoso Pereira (Osmar Cardoso)",
      "Matrícula": "3163256",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-09-15",
      "Fim": "2025-09-15"
    },
    {
      "Nome": "Osmar Cardoso Pereira (Osmar Cardoso)",
      "Matrícula": "3163256",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-17",
      "Fim": "2025-10-17"
    },
    {
      "Nome": "Osmar Cardoso Pereira (Osmar Cardoso)",
      "Matrícula": "3163256",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-10-20",
      "Fim": "2025-10-22"
    },
    {
      "Nome": "Osmar Cardoso Pereira (Osmar Cardoso)",
      "Matrícula": "3163256",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-11-22",
      "Fim": "2025-11-27"
    },
    {
      "Nome": "Osmar Cardoso Pereira (Osmar Cardoso)",
      "Matrícula": "3163256",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-11-22",
      "Fim": "2025-11-22"
    },
    {
      "Nome": "Osmar Cardoso Pereira (Osmar Cardoso)",
      "Matrícula": "3163256",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-12-12",
      "Fim": "2025-12-12"
    },
    {
      "Nome": "Osmar Cardoso Pereira (Osmar Cardoso)",
      "Matrícula": "3163256",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-12-15",
      "Fim": "2025-12-24"
    },
    {
      "Nome": "Osni da Silva Santos (Osni Santos)",
      "Matrícula": "1917832",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2024-12-24",
      "Fim": "2025-01-02"
    },
    {
      "Nome": "Osni da Silva Santos (Osni Santos)",
      "Matrícula": "1917832",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-01-17",
      "Fim": "2025-01-21"
    },
    {
      "Nome": "Osni da Silva Santos (Osni Santos)",
      "Matrícula": "1917832",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-02-18",
      "Fim": "2025-02-19"
    },
    {
      "Nome": "Osni da Silva Santos (Osni Santos)",
      "Matrícula": "1917832",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-02-22",
      "Fim": "2025-02-24"
    },
    {
      "Nome": "Osni da Silva Santos (Osni Santos)",
      "Matrícula": "1917832",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-02-26",
      "Fim": "2025-03-02"
    },
    {
      "Nome": "Osni da Silva Santos (Osni Santos)",
      "Matrícula": "1917832",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-03-06",
      "Fim": "2025-03-20"
    },
    {
      "Nome": "Osni da Silva Santos (Osni Santos)",
      "Matrícula": "1917832",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-03-20",
      "Fim": "2025-04-03"
    },
    {
      "Nome": "Osni da Silva Santos (Osni Santos)",
      "Matrícula": "1917832",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-13",
      "Fim": "2025-05-13"
    },
    {
      "Nome": "Osni da Silva Santos (Osni Santos)",
      "Matrícula": "1917832",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-21",
      "Fim": "2025-05-21"
    },
    {
      "Nome": "Osni da Silva Santos (Osni Santos)",
      "Matrícula": "1917832",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-02",
      "Fim": "2025-06-02"
    },
    {
      "Nome": "Osni da Silva Santos (Osni Santos)",
      "Matrícula": "1917832",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-06-30",
      "Fim": "2025-07-19"
    },
    {
      "Nome": "Osni da Silva Santos (Osni Santos)",
      "Matrícula": "1917832",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-07-20",
      "Fim": "2025-07-22"
    },
    {
      "Nome": "Osni da Silva Santos (Osni Santos)",
      "Matrícula": "1917832",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-07-29",
      "Fim": "2025-08-07"
    },
    {
      "Nome": "Osni da Silva Santos (Osni Santos)",
      "Matrícula": "1917832",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-05",
      "Fim": "2025-08-05"
    },
    {
      "Nome": "Osni da Silva Santos (Osni Santos)",
      "Matrícula": "1917832",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-09",
      "Fim": "2025-08-09"
    },
    {
      "Nome": "Osni da Silva Santos (Osni Santos)",
      "Matrícula": "1917832",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-09-02",
      "Fim": "2025-09-02"
    },
    {
      "Nome": "Osni da Silva Santos (Osni Santos)",
      "Matrícula": "1917832",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-09-10",
      "Fim": "2025-09-10"
    },
    {
      "Nome": "Osni da Silva Santos (Osni Santos)",
      "Matrícula": "1917832",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-09-14",
      "Fim": "2025-09-17"
    },
    {
      "Nome": "Osni da Silva Santos (Osni Santos)",
      "Matrícula": "1917832",
      "Lotação": "NPF/DEL03-DF",
      "Código": "81",
      "Sigla": "LICCPACITA",
      "Descrição": "Lic. Capacitação - EST NÃO Permite Frequência ?",
      "Início": "2025-10-01",
      "Fim": "2025-12-29"
    },
    {
      "Nome": "Osni da Silva Santos (Osni Santos)",
      "Matrícula": "1917832",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência ?",
      "Início": "2025-12-30",
      "Fim": "2026-01-10"
    },
    {
      "Nome": "Pamela Pereira Vieira (Pamela)",
      "Matrícula": "1515014",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-01-22",
      "Fim": "2025-01-24"
    },
    {
      "Nome": "Pamela Pereira Vieira (Pamela)",
      "Matrícula": "1515014",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-02-15",
      "Fim": "2025-02-18"
    },
    {
      "Nome": "Pamela Pereira Vieira (Pamela)",
      "Matrícula": "1515014",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-02-20",
      "Fim": "2025-02-22"
    },
    {
      "Nome": "Pamela Pereira Vieira (Pamela)",
      "Matrícula": "1515014",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-03-01",
      "Fim": "2025-03-01"
    },
    {
      "Nome": "Pamela Pereira Vieira (Pamela)",
      "Matrícula": "1515014",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-03-19",
      "Fim": "2025-03-19"
    },
    {
      "Nome": "Pamela Pereira Vieira (Pamela)",
      "Matrícula": "1515014",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-03-29",
      "Fim": "2025-03-29"
    },
    {
      "Nome": "Pamela Pereira Vieira (Pamela)",
      "Matrícula": "1515014",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-04-28",
      "Fim": "2025-05-01"
    },
    {
      "Nome": "Pamela Pereira Vieira (Pamela)",
      "Matrícula": "1515014",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-04",
      "Fim": "2025-05-04"
    },
    {
      "Nome": "Pamela Pereira Vieira (Pamela)",
      "Matrícula": "1515014",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-05",
      "Fim": "2025-06-05"
    },
    {
      "Nome": "Pamela Pereira Vieira (Pamela)",
      "Matrícula": "1515014",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-06-09",
      "Fim": "2025-06-17"
    },
    {
      "Nome": "Pamela Pereira Vieira (Pamela)",
      "Matrícula": "1515014",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência",
      "Início": "2025-07-14",
      "Fim": "2025-08-03"
    },
    {
      "Nome": "Pamela Pereira Vieira (Pamela)",
      "Matrícula": "1515014",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-07-15",
      "Fim": "2025-07-15"
    },
    {
      "Nome": "Pamela Pereira Vieira (Pamela)",
      "Matrícula": "1515014",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-04",
      "Fim": "2025-08-04"
    },
    {
      "Nome": "Pamela Pereira Vieira (Pamela)",
      "Matrícula": "1515014",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-09-01",
      "Fim": "2025-09-01"
    },
    {
      "Nome": "Pamela Pereira Vieira (Pamela)",
      "Matrícula": "1515014",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-09-09",
      "Fim": "2025-09-09"
    },
    {
      "Nome": "Pamela Pereira Vieira (Pamela)",
      "Matrícula": "1515014",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-09-21",
      "Fim": "2025-09-21"
    },
    {
      "Nome": "Pamela Pereira Vieira (Pamela)",
      "Matrícula": "1515014",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-09-29",
      "Fim": "2025-11-27"
    },
    {
      "Nome": "Pamela Pereira Vieira (Pamela)",
      "Matrícula": "1515014",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-11",
      "Fim": "2025-10-11"
    },
    {
      "Nome": "Pamela Pereira Vieira (Pamela)",
      "Matrícula": "1515014",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-10-14",
      "Fim": "2025-10-31"
    },
    {
      "Nome": "Pamela Pereira Vieira (Pamela)",
      "Matrícula": "1515014",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-11-17",
      "Fim": "2026-01-15"
    },
    {
      "Nome": "Rafael Varella Barca Ribeiro (Varella)",
      "Matrícula": "1515154",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-02-10",
      "Fim": "2025-02-14"
    },
    {
      "Nome": "Rafael Varella Barca Ribeiro (Varella)",
      "Matrícula": "1515154",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-04-07",
      "Fim": "2025-04-16"
    },
    {
      "Nome": "Rafael Varella Barca Ribeiro (Varella)",
      "Matrícula": "1515154",
      "Lotação": "NPF/DEL03-DF",
      "Código": "86",
      "Sigla": "LICPATERNI",
      "Descrição": "Lic. Paternidade - EST NÃO Permite Frequência",
      "Início": "2025-08-09",
      "Fim": "2025-08-13"
    },
    {
      "Nome": "Rafael Varella Barca Ribeiro (Varella)",
      "Matrícula": "1515154",
      "Lotação": "NPF/DEL03-DF",
      "Código": "324",
      "Sigla": "LICPATPROR",
      "Descrição": "Lic. Paternidade Prorrogação - EST NÃO Permite Frequência",
      "Início": "2025-08-14",
      "Fim": "2025-08-28"
    },
    {
      "Nome": "Rafael Varella Barca Ribeiro (Varella)",
      "Matrícula": "1515154",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-08-29",
      "Fim": "2025-09-12"
    },
    {
      "Nome": "Roberto Soares Estelles (Estelles)",
      "Matrícula": "1343886",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-03-29",
      "Fim": "2025-03-29"
    },
    {
      "Nome": "Roberto Soares Estelles (Estelles)",
      "Matrícula": "1343886",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-04-14",
      "Fim": "2025-04-14"
    },
    {
      "Nome": "Roberto Soares Estelles (Estelles)",
      "Matrícula": "1343886",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-05-04",
      "Fim": "2025-05-12"
    },
    {
      "Nome": "Roberto Soares Estelles (Estelles)",
      "Matrícula": "1343886",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-24",
      "Fim": "2025-05-24"
    },
    {
      "Nome": "Roberto Soares Estelles (Estelles)",
      "Matrícula": "1343886",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-01",
      "Fim": "2025-06-01"
    },
    {
      "Nome": "Roberto Soares Estelles (Estelles)",
      "Matrícula": "1343886",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-05",
      "Fim": "2025-06-05"
    },
    {
      "Nome": "Roberto Soares Estelles (Estelles)",
      "Matrícula": "1343886",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-29",
      "Fim": "2025-06-29"
    },
    {
      "Nome": "Roberto Soares Estelles (Estelles)",
      "Matrícula": "1343886",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-16",
      "Fim": "2025-08-16"
    },
    {
      "Nome": "Roberto Soares Estelles (Estelles)",
      "Matrícula": "1343886",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-08-20",
      "Fim": "2025-08-27"
    },
    {
      "Nome": "Roberto Soares Estelles (Estelles)",
      "Matrícula": "1343886",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-28",
      "Fim": "2025-08-28"
    },
    {
      "Nome": "Roberto Soares Estelles (Estelles)",
      "Matrícula": "1343886",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-09-25",
      "Fim": "2025-09-25"
    },
    {
      "Nome": "Roberto Soares Estelles (Estelles)",
      "Matrícula": "1343886",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-11",
      "Fim": "2025-10-11"
    },
    {
      "Nome": "Roberto Soares Estelles (Estelles)",
      "Matrícula": "1343886",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-11-03",
      "Fim": "2025-11-16"
    },
    {
      "Nome": "Roberto Soares Estelles (Estelles)",
      "Matrícula": "1343886",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-11-28",
      "Fim": "2025-11-28"
    },
    {
      "Nome": "Roberto Soares Estelles (Estelles)",
      "Matrícula": "1343886",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-12-02",
      "Fim": "2025-12-14"
    },
    {
      "Nome": "Romero Moreira Tolentino (Tolentino)",
      "Matrícula": "2194304",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-01-01",
      "Fim": "2025-01-10"
    },
    {
      "Nome": "Romero Moreira Tolentino (Tolentino)",
      "Matrícula": "2194304",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-25",
      "Fim": "2025-06-25"
    },
    {
      "Nome": "Romero Moreira Tolentino (Tolentino)",
      "Matrícula": "2194304",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-07-25",
      "Fim": "2025-07-25"
    },
    {
      "Nome": "Romero Moreira Tolentino (Tolentino)",
      "Matrícula": "2194304",
      "Lotação": "NPF/DEL03-DF",
      "Código": "32",
      "Sigla": "AFTRPPTPOL",
      "Descrição": "Afas. Est/Prog.Trein.(Congr-Encon) País C/Ônus Limit - EST NÃO Permite Frequência",
      "Início": "2025-10-02",
      "Fim": "2025-11-11"
    },
    {
      "Nome": "Romero Moreira Tolentino (Tolentino)",
      "Matrícula": "2194304",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-11-25",
      "Fim": "2025-12-14"
    },
    {
      "Nome": "Romero Moreira Tolentino (Tolentino)",
      "Matrícula": "2194304",
      "Lotação": "NPF/DEL03-DF",
      "Código": "86",
      "Sigla": "LICPATERNI",
      "Descrição": "Lic. Paternidade - EST NÃO Permite Frequência",
      "Início": "2025-12-15",
      "Fim": "2026-01-03"
    },
    {
      "Nome": "Romero Moreira Tolentino (Tolentino)",
      "Matrícula": "2194304",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2026-01-05",
      "Fim": "2026-01-14"
    },
    {
      "Nome": "Thiago Martins da Silva (Thiago Martins)",
      "Matrícula": "3212033",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-05-18",
      "Fim": "2025-05-22"
    },
    {
      "Nome": "Thiago Martins da Silva (Thiago Martins)",
      "Matrícula": "3212033",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-26",
      "Fim": "2025-05-26"
    },
    {
      "Nome": "Thiago Martins da Silva (Thiago Martins)",
      "Matrícula": "3212033",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-30",
      "Fim": "2025-05-30"
    },
    {
      "Nome": "Thiago Martins da Silva (Thiago Martins)",
      "Matrícula": "3212033",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-03",
      "Fim": "2025-06-03"
    },
    {
      "Nome": "Thiago Martins da Silva (Thiago Martins)",
      "Matrícula": "3212033",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-07-25",
      "Fim": "2025-07-25"
    },
    {
      "Nome": "Thiago Martins da Silva (Thiago Martins)",
      "Matrícula": "3212033",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-07-28",
      "Fim": "2025-07-28"
    },
    {
      "Nome": "Thiago Martins da Silva (Thiago Martins)",
      "Matrícula": "3212033",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-08-19",
      "Fim": "2025-08-19"
    },
    {
      "Nome": "Thiago Martins da Silva (Thiago Martins)",
      "Matrícula": "3212033",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-26",
      "Fim": "2025-08-26"
    },
    {
      "Nome": "Thiago Martins da Silva (Thiago Martins)",
      "Matrícula": "3212033",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-30",
      "Fim": "2025-08-30"
    },
    {
      "Nome": "Thiago Martins da Silva (Thiago Martins)",
      "Matrícula": "3212033",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-09-15",
      "Fim": "2025-09-24"
    },
    {
      "Nome": "Thiago Martins da Silva (Thiago Martins)",
      "Matrícula": "3212033",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-09-27",
      "Fim": "2025-09-27"
    },
    {
      "Nome": "Thiago Martins da Silva (Thiago Martins)",
      "Matrícula": "3212033",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-09-29",
      "Fim": "2025-10-13"
    },
    {
      "Nome": "Thiago Martins da Silva (Thiago Martins)",
      "Matrícula": "3212033",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-21",
      "Fim": "2025-10-21"
    },
    {
      "Nome": "Thiago Martins da Silva (Thiago Martins)",
      "Matrícula": "3212033",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-29",
      "Fim": "2025-10-29"
    },
    {
      "Nome": "Thiago Martins da Silva (Thiago Martins)",
      "Matrícula": "3212033",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-11-18",
      "Fim": "2025-11-18"
    },
    {
      "Nome": "Thiago Martins da Silva (Thiago Martins)",
      "Matrícula": "3212033",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-12-16",
      "Fim": "2025-12-16"
    },
    {
      "Nome": "Victor Henrique Santana de Souza (Victor Henrique)",
      "Matrícula": "3211776",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-04-24",
      "Fim": "2025-04-24"
    },
    {
      "Nome": "Victor Henrique Santana de Souza (Victor Henrique)",
      "Matrícula": "3211776",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-11",
      "Fim": "2025-06-11"
    },
    {
      "Nome": "Victor Henrique Santana de Souza (Victor Henrique)",
      "Matrícula": "3211776",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-07-05",
      "Fim": "2025-07-05"
    },
    {
      "Nome": "Victor Henrique Santana de Souza (Victor Henrique)",
      "Matrícula": "3211776",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-07-07",
      "Fim": "2025-07-12"
    },
    {
      "Nome": "Victor Henrique Santana de Souza (Victor Henrique)",
      "Matrícula": "3211776",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-08-18",
      "Fim": "2025-08-22"
    },
    {
      "Nome": "Victor Henrique Santana de Souza (Victor Henrique)",
      "Matrícula": "3211776",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-08-26",
      "Fim": "2025-08-26"
    },
    {
      "Nome": "Victor Henrique Santana de Souza (Victor Henrique)",
      "Matrícula": "3211776",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-09-23",
      "Fim": "2025-09-23"
    },
    {
      "Nome": "Victor Henrique Santana de Souza (Victor Henrique)",
      "Matrícula": "3211776",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-07",
      "Fim": "2025-10-07"
    },
    {
      "Nome": "Victor Henrique Santana de Souza (Victor Henrique)",
      "Matrícula": "3211776",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-19",
      "Fim": "2025-10-19"
    },
    {
      "Nome": "Victor Henrique Santana de Souza (Victor Henrique)",
      "Matrícula": "3211776",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2026-01-02",
      "Fim": "2026-01-14"
    },
    {
      "Nome": "Wagner Dias de Souza (Dias II)",
      "Matrícula": "1986058",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-01-13",
      "Fim": "2025-01-13"
    },
    {
      "Nome": "Wagner Dias de Souza (Dias II)",
      "Matrícula": "1986058",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-02-26",
      "Fim": "2025-02-27"
    },
    {
      "Nome": "Wagner Dias de Souza (Dias II)",
      "Matrícula": "1986058",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-05-19",
      "Fim": "2025-06-02"
    },
    {
      "Nome": "Wagner Dias de Souza (Dias II)",
      "Matrícula": "1986058",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-06-02",
      "Fim": "2025-06-06"
    },
    {
      "Nome": "Wagner Dias de Souza (Dias II)",
      "Matrícula": "1986058",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-06-05",
      "Fim": "2025-07-09"
    },
    {
      "Nome": "Wagner Dias de Souza (Dias II)",
      "Matrícula": "1986058",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-07-10",
      "Fim": "2025-07-29"
    },
    {
      "Nome": "Wagner Dias de Souza (Dias II)",
      "Matrícula": "1986058",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-07-30",
      "Fim": "2025-08-18"
    },
    {
      "Nome": "Wagner Dias de Souza (Dias II)",
      "Matrícula": "1986058",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-09-01",
      "Fim": "2025-09-02"
    },
    {
      "Nome": "Wagner Dias de Souza (Dias II)",
      "Matrícula": "1986058",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-09-08",
      "Fim": "2025-09-22"
    },
    {
      "Nome": "Wagner Dias de Souza (Dias II)",
      "Matrícula": "1986058",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência ?",
      "Início": "2025-10-06",
      "Fim": "2025-10-07"
    },
    {
      "Nome": "Wagner Dias de Souza (Dias II)",
      "Matrícula": "1986058",
      "Lotação": "NPF/DEL03-DF",
      "Código": "90",
      "Sigla": "LICMDPEFAM",
      "Descrição": "Lic. por Motivo de Doença em Pesssoa da Família - EST NÃO Permite Frequência",
      "Início": "2025-10-31",
      "Fim": "2025-10-31"
    },
    {
      "Nome": "Wagner Dias de Souza (Dias II)",
      "Matrícula": "1986058",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-11-21",
      "Fim": "2025-11-21"
    },
    {
      "Nome": "Wagner Dias de Souza (Dias II)",
      "Matrícula": "1986058",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-11-28",
      "Fim": "2025-11-29"
    },
    {
      "Nome": "Wagner Dias de Souza (Dias II)",
      "Matrícula": "1986058",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-12-22",
      "Fim": "2025-12-31"
    },
    {
      "Nome": "Wagner Dias de Souza (Dias II)",
      "Matrícula": "1986058",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2026-01-01",
      "Fim": "2026-01-10"
    },
    {
      "Nome": "Wilson Alves Costa (W. Costa)",
      "Matrícula": "1398311",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-01-06",
      "Fim": "2025-01-10"
    },
    {
      "Nome": "Wilson Alves Costa (W. Costa)",
      "Matrícula": "1398311",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência",
      "Início": "2025-01-14",
      "Fim": "2025-01-15"
    },
    {
      "Nome": "Wilson Alves Costa (W. Costa)",
      "Matrícula": "1398311",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-04-15",
      "Fim": "2025-04-15"
    },
    {
      "Nome": "Wilson Alves Costa (W. Costa)",
      "Matrícula": "1398311",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-04-20",
      "Fim": "2025-04-20"
    },
    {
      "Nome": "Wilson Alves Costa (W. Costa)",
      "Matrícula": "1398311",
      "Lotação": "NPF/DEL03-DF",
      "Código": "84",
      "Sigla": "LICTRSAUDE",
      "Descrição": "Lic. Tratamento de Saúde - EST NÃO Permite Frequência",
      "Início": "2025-04-23",
      "Fim": "2025-04-25"
    },
    {
      "Nome": "Wilson Alves Costa (W. Costa)",
      "Matrícula": "1398311",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-02",
      "Fim": "2025-05-02"
    },
    {
      "Nome": "Wilson Alves Costa (W. Costa)",
      "Matrícula": "1398311",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-22",
      "Fim": "2025-05-22"
    },
    {
      "Nome": "Wilson Alves Costa (W. Costa)",
      "Matrícula": "1398311",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-05-30",
      "Fim": "2025-05-30"
    },
    {
      "Nome": "Wilson Alves Costa (W. Costa)",
      "Matrícula": "1398311",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-23",
      "Fim": "2025-06-23"
    },
    {
      "Nome": "Wilson Alves Costa (W. Costa)",
      "Matrícula": "1398311",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-06-27",
      "Fim": "2025-06-27"
    },
    {
      "Nome": "Wilson Alves Costa (W. Costa)",
      "Matrícula": "1398311",
      "Lotação": "NPF/DEL03-DF",
      "Código": "81",
      "Sigla": "LICCPACITA",
      "Descrição": "Lic. Capacitação - EST NÃO Permite Frequência ?",
      "Início": "2025-07-01",
      "Fim": "2025-09-28"
    },
    {
      "Nome": "Wilson Alves Costa (W. Costa)",
      "Matrícula": "1398311",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-10-01",
      "Fim": "2025-10-01"
    },
    {
      "Nome": "Wilson Alves Costa (W. Costa)",
      "Matrícula": "1398311",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência",
      "Início": "2025-10-04",
      "Fim": "2025-11-11"
    },
    {
      "Nome": "Wilson Alves Costa (W. Costa)",
      "Matrícula": "1398311",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-11-14",
      "Fim": "2025-11-14"
    },
    {
      "Nome": "Wilson Alves Costa (W. Costa)",
      "Matrícula": "1398311",
      "Lotação": "NPF/DEL03-DF",
      "Código": "356",
      "Sigla": "AUDBANHO",
      "Descrição": "Ausência para débito em Banco de Horas - EST NÃO Permite Frequência ?",
      "Início": "2025-12-04",
      "Fim": "2025-12-04"
    },
    {
      "Nome": "Wilson Alves Costa (W. Costa)",
      "Matrícula": "1398311",
      "Lotação": "NPF/DEL03-DF",
      "Código": "42",
      "Sigla": "AFVISEPACO",
      "Descrição": "Afas. Viagem/Serv País Com Ônus - EST Permite Frequência",
      "Início": "2025-12-10",
      "Fim": "2025-12-23"
    },
    {
      "Nome": "Wilson Alves Costa (W. Costa)",
      "Matrícula": "1398311",
      "Lotação": "NPF/DEL03-DF",
      "Código": "221",
      "Sigla": "HEFERIAS",
      "Descrição": "Férias - EST NÃO Permite Frequência",
      "Início": "2025-12-25",
      "Fim": "2026-01-18"
    }
  ]
}
```    
    [[/knowledge_second_set_json_ptbr]]    
    </knowledge_second_set_json_ptbr>
  </input_data>

  <instructions>
    <instruction>1. Ler [[knowledge_first_set_ptbr]] e dividir em linhas preservando o índice real da linha no texto original (1-based), inclusive linhas vazias para referência; linhas vazias NÃO geram item em "dataset_a_parsed", mas contam em "dataset_a_lines_total".</instruction>

    <instruction>2. Para cada linha não vazia de A, extrair um intervalo:
      (a) Se houver duas datas claras indicando início e fim (ex.: "de X a Y", "X até Y"), use-as.
      (b) Se houver exatamente uma data inequívoca, aplicar a política em &lt;single_date_policy&gt;.
      (c) Se houver mais de duas datas, só aceitar se existir um par (início, fim) inequívoco; caso contrário, erro do tipo "ambiguous_interval".
      (d) Se não for possível extrair datas, erro do tipo "no_date_found".</instruction>

    <instruction>3. Fazer parse de [[knowledge_second_set_json_ptbr]] como JSON. Se falhar, registrar um único erro "invalid_json" e encerrar a etapa de parsing de B (não inventar registros).</instruction>

    <instruction>4. Se o JSON for válido, validar que ele é uma lista (array) de objetos. Para cada objeto, validar presença das chaves exatamente:
      "Nome","Matrícula","Lotação","Código","Sigla","Descrição","Início","Fim".
      Se faltar alguma, registrar erro "missing_required_key" para aquele record_index.</instruction>

    <instruction>5. Para cada registro válido de B, extrair o intervalo usando exatamente os campos "Início" (início) e "Fim" (fim). Se algum não for data válida em formato suportado/interpretável, registrar erro "invalid_date".</instruction>

    <instruction>6. Normalizar todas as datas extraídas (A e B) para ISO (YYYY-MM-DD). Guardar também os textos originais das datas.</instruction>

    <instruction>7. Validar intervalos (A e B): se inicio_iso &gt; fim_iso, registrar erro "invalid_interval" e NÃO incluir esse item na checagem de colisões.</instruction>

    <instruction>8. Checar colisões: para cada intervalo válido de A contra cada intervalo válido de B, aplicar a regra em &lt;overlap_definition&gt;. Se colidir, registrar um item em "collisions" e calcular a janela de sobreposição:
      overlap_start = max(a_inicio, b_inicio), overlap_end = min(a_fim, b_fim).</instruction>

    <instruction>9. Produzir saída FINAL estritamente como JSON conforme &lt;output_format_specification&gt;, com contagens coerentes com os arrays gerados.</instruction>
  </instructions>

  <output_format_specification>
    <json_schema>
      {
        "report_metadata": {
          "generated_at": "string|null (ISO-8601 se disponível; caso contrário null)",
          "timezone": "string",
          "overlap_rule": "string",
          "single_date_policy": "string",
          "counts": {
            "dataset_a_lines_total": "integer",
            "dataset_a_items_total_nonempty": "integer",
            "dataset_a_items_parsed": "integer",
            "dataset_a_items_errors": "integer",
            "dataset_b_records_total": "integer",
            "dataset_b_records_parsed": "integer",
            "dataset_b_records_errors": "integer",
            "collisions_total": "integer"
          }
        },
        "dataset_a_parsed": [
          {
            "original_line_number": "integer (1-based, no texto original)",
            "original_line": "string",
            "start_original": "string|null",
            "end_original": "string|null",
            "start_iso": "string|null (YYYY-MM-DD)",
            "end_iso": "string|null (YYYY-MM-DD)",
            "notes": "string|null"
          }
        ],
        "dataset_b_parsed": [
          {
            "record_index": "integer (0-based)",
            "Nome": "string|null",
            "Matrícula": "string|null",
            "Lotação": "string|null",
            "Código": "string|null",
            "Sigla": "string|null",
            "Descrição": "string|null",
            "Início_original": "string|null",
            "Fim_original": "string|null",
            "Início_iso": "string|null (YYYY-MM-DD)",
            "Fim_iso": "string|null (YYYY-MM-DD)",
            "notes": "string|null"
          }
        ],
        "errors": [
          {
            "source": "dataset_a|dataset_b",
            "original_line_number": "integer|null",
            "record_index": "integer|null",
            "error_type": "invalid_json|missing_required_key|no_date_found|invalid_date|unsupported_date_format|ambiguous_interval|invalid_interval|other",
            "message": "string",
            "original_fragment": "string|null"
          }
        ],
        "collisions": [
          {
            "dataset_a_original_line_number": "integer",
            "dataset_b_record_index": "integer",
            "a_start_iso": "string",
            "a_end_iso": "string",
            "b_start_iso": "string",
            "b_end_iso": "string",
            "overlap_start_iso": "string",
            "overlap_end_iso": "string",
            "collision_reason": "string (ex.: inclusive_overlap)"
          }
        ]
      }
    </json_schema>
  </output_format_specification>

  <examples>
    <example>
      <input_data>
        <knowledge_first_set_ptbr>Férias: 10/01/2025 a 20/01/2025</knowledge_first_set_ptbr>
        <knowledge_second_set_json_ptbr>
          [
            {
              "Nome":"Ana",
              "Matrícula":"123",
              "Lotação":"X",
              "Código":"C1",
              "Sigla":"SG",
              "Descrição":"Plantão",
              "Início":"2025-01-15",
              "Fim":"2025-01-18"
            }
          ]
        </knowledge_second_set_json_ptbr>
      </input_data>
      <output>
        {
          "report_metadata":{
            "generated_at":null,
            "timezone":"America/Sao_Paulo",
            "overlap_rule":"inclusive",
            "single_date_policy":"one_day",
            "counts":{
              "dataset_a_lines_total":1,
              "dataset_a_items_total_nonempty":1,
              "dataset_a_items_parsed":1,
              "dataset_a_items_errors":0,
              "dataset_b_records_total":1,
              "dataset_b_records_parsed":1,
              "dataset_b_records_errors":0,
              "collisions_total":1
            }
          },
          "dataset_a_parsed":[
            {
              "original_line_number":1,
              "original_line":"Férias: 10/01/2025 a 20/01/2025",
              "start_original":"10/01/2025",
              "end_original":"20/01/2025",
              "start_iso":"2025-01-10",
              "end_iso":"2025-01-20",
              "notes":null
            }
          ],
          "dataset_b_parsed":[
            {
              "record_index":0,
              "Nome":"Ana",
              "Matrícula":"123",
              "Lotação":"X",
              "Código":"C1",
              "Sigla":"SG",
              "Descrição":"Plantão",
              "Início_original":"2025-01-15",
              "Fim_original":"2025-01-18",
              "Início_iso":"2025-01-15",
              "Fim_iso":"2025-01-18",
              "notes":null
            }
          ],
          "errors":[],
          "collisions":[
            {
              "dataset_a_original_line_number":1,
              "dataset_b_record_index":0,
              "a_start_iso":"2025-01-10",
              "a_end_iso":"2025-01-20",
              "b_start_iso":"2025-01-15",
              "b_end_iso":"2025-01-18",
              "overlap_start_iso":"2025-01-15",
              "overlap_end_iso":"2025-01-18",
              "collision_reason":"inclusive_overlap"
            }
          ]
        }
      </output>
    </example>
  </examples>
