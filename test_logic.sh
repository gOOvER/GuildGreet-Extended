echo "Testing luacheck logic locally..."

# Test if we have any lua files
lua_files=($(Get-ChildItem -Filter "*.lua" -Recurse | Select-Object -First 5 -ExpandProperty FullName))
echo "Found ${#lua_files[@]} lua files for testing"

# Test individual file processing approach
total_processed=0
for file in $lua_files; do
    echo "Would process: $file"
    total_processed=$((total_processed + 1))
done

echo "✅ Local test completed - would process $total_processed files individually"
