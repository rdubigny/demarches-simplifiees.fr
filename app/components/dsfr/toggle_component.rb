class Dsfr::ToggleComponent < ApplicationComponent
  def initialize(form:, target:, title:, disabled: nil, hint: nil, toggle_labels: { checked: 'Activé', unchecked: 'Désactivé' })
    @form = form
    @target = target
    @title = title
    @hint = hint
    @disabled = disabled
    @toggle_labels = toggle_labels
  end

  attr_reader :toggle_labels
end
