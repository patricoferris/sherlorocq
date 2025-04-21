for dir in ./rocq-sources/*.dev/; do
  newname="${dir%.dev/}"
  mv -- "$dir" "$newname"
done

