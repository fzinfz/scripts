### How it works

| Step | Description |
|------|-------------|
| **1. Scan** | Recursively lists all files under `NEW_DIR` and builds an in-memory index keyed by `filename\|size` |
| **2. Compare** | Recursively walks `OLD_DIR` and finds every file whose `name + size` matches something in the index |
| **3. Display** | Prints a formatted table of all duplicates (name, size, old path, new path) |
| **4. Confirm** | Prompts the user — you must type **`YES`** (all caps) to proceed; anything else aborts safely |
| **5. Delete** | Permanently deletes each duplicate from `OLD_DIR`, reports success/failure per file |

### How to run it

```powershell
# Allow script execution (if needed, one-time)
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned

# Run the script
.\cleanup_duplicates.ps1 [-VerifyHash]
```

### Safety notes
- Only **name + size** are compared (no hash). Files with the same name and size but different content would be flagged — review the table before typing `YES`.
- Deletion uses `Remove-Item -Force` (permanent, not Recycle Bin). Make sure `NEW_DIR` copies are intact before confirming.
- If you want hash-based comparison for extra safety, let me know and I'll add an optional `-VerifyHash` switch.