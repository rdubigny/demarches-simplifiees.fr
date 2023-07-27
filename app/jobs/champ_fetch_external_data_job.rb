class ChampFetchExternalDataJob < ApplicationJob
  include Dry::Monads[:result]

  def perform(champ, external_id)
    return if champ.external_id != external_id
    return if champ.data.present?

    Sentry.set_extras(external_id:)

    result = champ.fetch_external_data

    if result.is_a?(Dry::Monads::Result)
      case result
      in Success(data)
        pp "success #{data}"
        champ.update_with_external_data!(data:)
      in Failure(retryable: true, reason:)
        error = result.failure
        error.attempts = executions
        pp "retryable failure #{error}"
        champ.log_fetch_external_data_exception(error)
        raise reason
      in Failure(retryable: false, reason:)
        pp "failure #{result.failure}"
        champ.log_fetch_external_data_exception(result.failure)
        Sentry.capture_exception(reason)
      end
    elsif result.present?
      champ.update_with_external_data!(data: result)
    end
  end
end
