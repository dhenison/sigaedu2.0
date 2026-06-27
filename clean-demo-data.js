(function () {
  const resetVersion = "sigaedu_clean_dataset_2026_06_v2";
  if (localStorage.getItem(resetVersion)) return;

  localStorage.removeItem("sigaedu_clean_dataset_2026_06_v1");

  const emptyArrays = [
    "sigaedu_alunos",
    "sigaedu_turmas",
    "sigaedu_agenda",
    "sigaedu_ocorrencias",
    "sigaedu_solicitacoes",
    "sigaedu_aee_registros",
    "sigaedu_aee_tipificidades"
  ];
  const emptyObjects = [
    "sigaedu_frequencia",
    "sigaedu_calendario_2026"
  ];

  emptyArrays.forEach(key => localStorage.setItem(key, "[]"));
  emptyObjects.forEach(key => localStorage.setItem(key, "{}"));
  localStorage.setItem(resetVersion, "true");
})();
