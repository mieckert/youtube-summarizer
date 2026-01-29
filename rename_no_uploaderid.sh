for i in */*; do 
    # skip if string does not contain 2026
    [[ $i == *2026* ]] || continue   
    # split i into filename and extension; note that extension may be multiple parts, e.g., .info.json 
    filename=${i%%.*}
    extension=${i#${filename}.}
    echo "Renaming ${i} to ${filename}_NateBJones.${extension}"
    mv "${i}" "${filename}_NateBJones.${extension}"
done