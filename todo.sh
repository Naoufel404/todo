#!/bin/bash

# Fonction pour afficher un message d'erreur et quitter
display_error_and_exit() {
    echo "$1" >&2
    exit 1
}

# Fonction pour créer une tâche
create_task() {
    read -p "Titre de la tâche (requis): " title
    if [ -z "$title" ]; then
        display_error_and_exit "Le titre de la tâche est requis."
    fi

    read -p "Description de la tâche: " description
    read -p "Lieu de la tâche: " location
    read -p "Date limite (YYYY-MM-DD HH:MM): " due_date
    if [ -z "$due_date" ]; then
        display_error_and_exit "La date limite de la tâche est requise."
    fi

    # Générer un identifiant unique pour la tâche
    task_id=$(date +%s)

    # Marquer la tâche comme non terminée
    completed=false

    # Enregistrer la tâche dans un fichier
    echo "$task_id|$title|$description|$location|$due_date|$completed" >> tasks.txt

    echo "Tâche créée avec succès avec l'identifiant $task_id."
}

# Fonction pour mettre à jour une tâche
update_task() {
    read -p "Entrez l'identifiant de la tâche à mettre à jour: " task_id
    if ! grep -q "^$task_id|" tasks.txt; then
        display_error_and_exit "Aucune tâche trouvée avec cet identifiant."
    fi

    # Demander les nouvelles informations de la tâche
    read -p "Nouveau titre de la tâche: " new_title
    read -p "Nouvelle description de la tâche: " new_description
    read -p "Nouveau lieu de la tâche: " new_location
    read -p "Nouvelle date limite (YYYY-MM-DD HH:MM): " new_due_date

    # Mettre à jour la ligne correspondante dans le fichier des tâches
    sed -i "/^$task_id|/s/|[^|]*|[^|]*|[^|]*|[^|]*|/|$new_title|$new_description|$new_location|$new_due_date|/" tasks.txt

    echo "Tâche mise à jour avec succès."
}

# Fonction pour supprimer une tâche
delete_task() {
    read -p "Entrez l'identifiant de la tâche à supprimer: " task_id
    if ! grep -q "^$task_id|" tasks.txt; then
        display_error_and_exit "Aucune tâche trouvée avec cet identifiant."
    fi

    # Supprimer la ligne correspondante dans le fichier des tâches
    sed -i "/^$task_id|/d" tasks.txt

    echo "Tâche supprimée avec succès."
}

# Fonction pour afficher les informations d'une tâche
show_task_info() {
    read -p "Entrez l'identifiant de la tâche: " task_id
    if ! grep -q "^$task_id|" tasks.txt; then
        display_error_and_exit "Aucune tâche trouvée avec cet identifiant."
    fi

    # Afficher les informations de la tâche
    grep "^$task_id|" tasks.txt
}

# Fonction pour lister les tâches d'une journée donnée
list_tasks_by_day() {
    read -p "Entrez la date (YYYY-MM-DD) pour afficher les tâches: " target_date

    echo "Tâches terminées pour le $target_date :"
    grep "|$target_date" tasks.txt | grep "|true" | sed 's/|[^|]*$//'

    echo "Tâches non terminées pour le $target_date :"
    grep "|$target_date" tasks.txt | grep "|false" | sed 's/|[^|]*$//'
}

# Fonction pour rechercher une tâche par titre
search_task_by_title() {
    read -p "Entrez le titre de la tâche à rechercher: " search_title

    echo "Tâches correspondantes pour le titre '$search_title' :"
    grep "|$search_title|" tasks.txt
}

# Vérifier si le fichier des tâches existe, sinon le créer
touch tasks.txt

# Vérifier les arguments et appeler les fonctions appropriées
case "$1" in
    "create")
        create_task
        ;;
    "update")
        update_task
        ;;
    "delete")
        delete_task
        ;;
    "show")
        show_task_info
        ;;
    "list")
        list_tasks_by_day
        ;;
    "search")
        search_task_by_title
        ;;
    *)
        # Si aucun argument n'est fourni, afficher les tâches du jour
        list_tasks_by_day
        ;;
esac
