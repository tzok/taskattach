#! /bin/bash
# A script to attach files to Taskwarriors tasks and open them on demand
# Author: Tomasz Żok

# Check correctness of all input arguments
if [ $# -ne 1 -a $# -ne 2 ]
then
    echo 'Attach a file:       taskattach <ID> <PATH>'
    echo 'Open the attachment: taskattach <ID>'
    exit 1
elif [[ ! "$1" =~ [0-9]+ ]]
then
    echo "Invalid task id: $1"
    exit 1
elif [ $# -eq 2 -a ! -r "$2" ]
then
    echo "File is not readable: $2"
    exit 1
fi

# Get UUID of the task
uuid=$(task "$1" uuid)
if [ -z "$uuid" ]
then
    echo "Task with given id does not exist: $1"
    exit 1
fi

# Create directory for attachments if needed
directory="${XDG_DATA_HOME:-$HOME/.local/share}/taskattach/$uuid"
if [ ! -d "$directory" ]
then
    mkdir -p "$directory"
fi

if [ $# -eq 1 ]
then
    # Read all attachments, exit if none present
    attachments=($(task rc.defaultwidth=0 "$1" information\
        | tr -d "'"\
        | awk '$2 == "Annotation" && $4 == "Attachment:" { print $5 }'\
        | sort -u))
    if [ ${#attachments[@]} -eq 0 ]
    then
        echo "There are currently no attachments for task: $1"
        exit
    fi
    # Let user choose one
    select filename in ${attachments[@]}; do [ -n "$filename" ] && break; done
    # Check if it is existing
    filename="$directory/$filename"
    if [ ! -e "$filename" ]
    then
        echo "Warning! The file does not exist: $filename"
        exit 1
    fi
    # Get MIME type of the file
    mime=$(xdg-mime query filetype "$filename")
    if [ "${mime%%;*}" == "text/plain" ]
    then
        # Special case, for plaintext file invoke editor
        editor=${EDITOR:-vim}
        editor=$(which "$editor" 2> /dev/null)
        [ -x "$editor" ] && "$editor" "$filename"
    else
        # Otherwise call for the default handler of the filetype
        xdg-open "$filename"
    fi
else
    # Change whitespace in filename to underscores
    filename=$(basename "$2")
    nowhitespace=$(echo "$filename" | sed 's/ /_/g')
    destination="$directory/$nowhitespace"
    test -e "$destination"
    exists=$?
    # Explicitly ask if the file of that name already exists
    cp --interactive "$2" "$destination"
    # Add annotation only if the attachment is a new one
    if [ $exists -ne 0 ]
    then
        task "$1" annotate "Attachment: $nowhitespace"
    fi
fi
