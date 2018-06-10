#!/bin/bash

DOCS_HOME="../../src/main/resources/docs/"
DESCRIPTION_HOME="${DOCS_HOME}description/"
VERSION="0.5.0"

git clone https://github.com/koalaman/shellcheck.git
git clone https://github.com/koalaman/shellcheck.wiki.git

cd shellcheck.wiki

# patterns.json
for f in SC*; do
  pattern_id=${f%.*}
  [ -n "$patterns" ] && patterns+=","
  internal_id=`echo $pattern_id | grep -o '[0-9]\+'`
  severity=`grep -hR $internal_id ../shellcheck`
  case $severity in
    *"err"*) level="Error" ;;
    *"ErrorC"*) level="Error" ;;
    *"warn"*) level="Warning" ;;
    *"WarningC"*) level="Warning" ;;
    *"info"*) level="Info" ;;
    *"InfoC"*) level="Info" ;;
    *) level="Info" ;;
  esac
  patterns+=$(jq -cMn --arg patternId "$pattern_id" --arg level "$level" '{"patternId": $patternId, "level": $level, "category": "CodeStyle"}')
done

jq -Mn --arg version "$VERSION" --argjson patterns "[$patterns]" '{"name": "shellcheck", "version": $version, "patterns": $patterns}' > "${DOCS_HOME}patterns.json"

# description.json
for f in SC*; do
  pattern_id=${f%.*}
  title=$(head -n 1 $f | sed 's/^#* *//')
  [ -n "$descriptions" ] && descriptions+=","
  descriptions+=$(jq -cMn --arg patternId "$pattern_id" --arg title "$title" '{"patternId": $patternId, "title": $title, "description": $title, "timeToFix": 5}')
done

jq -Mn --argjson descriptions "[$descriptions]" '$descriptions' > "${DESCRIPTION_HOME}description.json"

# Documentation
for f in SC*; do
   file=$DESCRIPTION_HOME$f
   cp $f $file
   pattern_id=${f%.*}
   echo "" >> $file
   echo "[Source](https://github.com/koalaman/shellcheck/wiki/${pattern_id})" >> $file
   echo "" >> $file
done
