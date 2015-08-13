module ChangeHelpers
  def store_preaction_state
    store_jobs_state
    store_mailer_state
    store_model_counts
  end
end
