%Doctor.Config{
  ignore_modules: [],
  ignore_paths: [],
  # Module-level @doc floors stay soft while inherited v1 resources catch up.
  # Overall coverage is the CI gate; raise floors as docs improve.
  min_module_doc_coverage: 0,
  min_module_spec_coverage: 0,
  min_overall_doc_coverage: 40,
  min_overall_moduledoc_coverage: 70,
  min_overall_spec_coverage: 0,
  exception_moduledoc_required: true,
  raise: true,
  reporter: Doctor.Reporters.Full,
  struct_type_spec_required: false,
  umbrella: false,
  failed: false
}
