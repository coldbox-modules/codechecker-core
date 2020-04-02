```
   ______          __     ________              __                ______
  / ____/___  ____/ /__  / ____/ /_  ___  _____/ /_____  _____   / ____/___  ________
 / /   / __ \/ __  / _ \/ /   / __ \/ _ \/ ___/ //_/ _ \/ ___/  / /   / __ \/ ___/ _ \
/ /___/ /_/ / /_/ /  __/ /___/ / / /  __/ /__/ ,< /  __/ /     / /___/ /_/ / /  /  __/
\____/\____/\__,_/\___/\____/_/ /_/\___/\___/_/|_|\___/_/      \____/\____/_/   \___/
```

# Codechecker Core

This repo is a set of core services for the Codechecker library.

You probably want to use these services via:

* The standalone Codechecker App https://github.com/Ortus-Solutions/CodeChecker/
* The CommandBox Codechecker CLI command https://github.com/commandbox-modules/commandbox-codechecker

These services can be used directly in any implementation you choose, but you'll likely want to use one of the projects above, both of which bundle this core library.

# Ignoring rules
Individual lines can be ignored in one of two ways:

`codechecker disable-line`

`codechecker disable-next-line`

Both tag & script syntax are supported, as well as multi-line & single-line comment syntax (e.g. `//` or `/* */`)

After the invocation above, specific rules or categories can be provided:
```
// Disable a category titled "Formatters"
codechecker disable-line Formatters

// Disable categories titled "Formatters" and "Standards"
codechecker disable-line Formatters | Standards

// Disable the rule titled "htmlEditFormat" in the category "Formatters"
codechecker disable-line Formatters: htmlEditFormat
```

## Caveat
Support for ignoring blocks of code or whole files has not been implemented.
