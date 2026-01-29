set -eaxo pipefail
for file in */*@*; do
    #echo mv -v "$file" "${file//@/}"
    mv -v "$file" "${file//@/}"
done