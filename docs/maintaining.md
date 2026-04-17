# Maintaining the registry

## Adding a new version of an existing port

Example: bumping inflare from 0.2.1 to 0.2.2.

**1. Update the port files**

Edit `ports/inflare/vcpkg.json` — bump the `version` field.

Edit `ports/inflare/portfile.cmake` — update `REF` (if needed) and set `SHA512` to `0`.
Then install the port once; vcpkg will fail and print the correct SHA512 in the error output.
Replace `0` with that value.

**2. Commit the port changes**

```bash
git add ports/inflare/
git commit -m "inflare 0.2.2"
```

**3. Get the new git tree SHA**

```bash
git rev-parse HEAD:ports/inflare
```

**4. Append to the port's version file**

Add a new entry at the top of the `versions` array in `versions/i-/inflare.json`:

```json
{
    "versions": [
        {
            "version": "0.2.2",
            "port-version": 0,
            "git-tree": "<SHA from step 3>"
        },
        {
            "version": "0.2.1",
            "port-version": 0,
            "git-tree": "2af28dfc4cbbe85287cb5a9511d651f9e00ee042"
        }
    ]
}
```

**5. Update baseline**

In `versions/baseline.json`, change the inflare entry to the new version:

```json
"inflare": { "baseline": "0.2.2", "port-version": 0 }
```

**6. Commit and push**

```bash
git add versions/
git commit -m "Register inflare 0.2.2"
git push
```

**7. Update consumers**

Copy the new registry HEAD SHA (`git rev-parse HEAD`) into the `baseline` field of the
`vcpkg-configuration.json` in every consuming repo.

---

## Adding a brand new port

1. Create `ports/<name>/vcpkg.json`, `portfile.cmake`, and `usage`.
2. Commit: `git add ports/<name>/ && git commit -m "Add <name> port"`
3. Get the tree SHA: `git rev-parse HEAD:ports/<name>`
4. Create `versions/<first-letter>-/<name>.json` with a single entry pointing to that SHA.
5. Add the port to `versions/baseline.json`.
6. Commit versions, push, update consumers.

---

## Port version file naming

The version file lives under `versions/<first-letter>-/<name>.json`.
Examples: `errors` → `e-/errors.json`, `kvalog` → `k-/kvalog.json`.

## Port-version vs version

`port-version` is incremented (0 → 1 → 2 …) when the port files change but the
upstream source version does not. Reset it to 0 whenever the upstream `version` bumps.
