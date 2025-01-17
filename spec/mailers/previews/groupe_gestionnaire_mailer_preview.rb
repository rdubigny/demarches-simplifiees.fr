class GroupeGestionnaireMailerPreview < ActionMailer::Preview
  def notify_removed_gestionnaire
    groupe_gestionnaire = GroupeGestionnaire.new(name: 'un groupe gestionnaire')
    current_super_admin_email = 'admin@dgfip.com'
    gestionnaire = Gestionnaire.new(user: user)
    GroupeGestionnaireMailer.notify_removed_gestionnaire(groupe_gestionnaire, gestionnaire.email, current_super_admin_email)
  end

  def notify_added_gestionnaires
    groupe_gestionnaire = GroupeGestionnaire.new(name: 'un groupe gestionnaire')
    current_super_admin_email = 'admin@dgfip.com'
    gestionnaires = [Gestionnaire.new(user: user)]
    GroupeGestionnaireMailer.notify_added_gestionnaires(groupe_gestionnaire, gestionnaires, current_super_admin_email)
  end

  def notify_removed_administrateur
    groupe_gestionnaire = GroupeGestionnaire.new(name: 'un groupe gestionnaire')
    current_super_admin_email = 'admin@dgfip.com'
    administrateur = Administrateur.new(user: user)
    GroupeGestionnaireMailer.notify_removed_administrateur(groupe_gestionnaire, administrateur.email, current_super_admin_email)
  end

  def notify_added_administrateurs
    groupe_gestionnaire = GroupeGestionnaire.new(name: 'un groupe gestionnaire')
    current_super_admin_email = 'admin@dgfip.com'
    administrateurs = [Administrateur.new(user: user)]
    GroupeGestionnaireMailer.notify_added_administrateurs(groupe_gestionnaire, administrateurs, current_super_admin_email)
  end

  private

  def user
    User.new(id: 10, email: 'test@exemple.fr')
  end
end
