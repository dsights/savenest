#!/bin/bash

# ----------------- CONFIGURATION -----------------
SENDER_NAME="SaveNest"
SENDER_EMAIL="contact@savenest.au"
# ---------------------------------------------------

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 \"<Subject>\" <path_to_template> <path_to_email_list>"
    exit 1
fi

SUBJECT=$1
TEMPLATE_PATH=$2
EMAIL_LIST_PATH=$3
MSMTPRC_PATH="$(dirname "$0")/msmtprc"

if [ ! -f "$TEMPLATE_PATH" ]; then
    echo "Error: Template file not found at '$TEMPLATE_PATH'"
    exit 1
fi

if [ ! -f "$EMAIL_LIST_PATH" ]; then
    echo "Error: Email list file not found at '$EMAIL_LIST_PATH'"
    exit 1
fi

BOUNDARY="===============$(openssl rand -hex 15)=="
PLAIN_TEXT_BODY=$(sed -e 's/<[^>]*>//g' "$TEMPLATE_PATH")

while IFS= read -r RECIPIENT_EMAIL || [[ -n "$RECIPIENT_EMAIL" ]]; do
    if [ -z "$RECIPIENT_EMAIL" ]; then
        continue
    fi

    (
        echo "From: \"$SENDER_NAME\" <$SENDER_EMAIL>"
        echo "To: $RECIPIENT_EMAIL"
        echo "Subject: $SUBJECT"
        echo "MIME-Version: 1.0"
        echo "Content-Type: multipart/alternative; boundary=\"$BOUNDARY\""
        echo ""
        echo "--$BOUNDARY"
        echo "Content-Type: text/plain; charset=UTF-8"
        echo "Content-Transfer-Encoding: 7bit"
        echo ""
        echo "$PLAIN_TEXT_BODY"
        echo ""
        echo "--$BOUNDARY"
        echo "Content-Type: text/html; charset=UTF-8"
        echo "Content-Transfer-Encoding: 7bit"
        echo ""
        cat "$TEMPLATE_PATH"
        echo ""
        echo "--$BOUNDARY--"
    ) | msmtp --file="$MSMTPRC_PATH" "$RECIPIENT_EMAIL"

    echo "Email sent to $RECIPIENT_EMAIL"
    sleep 10
done < "$EMAIL_LIST_PATH"

echo "Bulk email sending complete."
