class GroupeGestionnaire::Card::CommentairesComponent < ApplicationComponent
  def initialize(groupe_gestionnaire:, administrateur:, path:)
    @groupe_gestionnaire = groupe_gestionnaire
    @administrateur = administrateur
    @path = path
  end

  def number_commentaires
    if @administrateur
      @administrateur.commentaire_groupe_gestionnaires.size
    else
      @groupe_gestionnaire.commentaire_groupe_gestionnaires.select(:sender_id, :sender_type).distinct.size
    end
  end
end
