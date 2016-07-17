# Atom Journal

A journal and note-taking assistant for Atom Editor. I use this for taking notes in classes and for writing in my journal. I write them all in Markdown files that I sync with [Syncthing]().

You will need to add a journal entry to your `config.cson` file. You must set the base directory to where your documents folder is located, then you must create an entry for each of your notebooks.

```cson
journal:
  baseDir: "/home/username/Documents"
  notebooks:
    church: {}
    rel333:
      weekOffset: 22
    journal: {}
```

Available options:

- `weekOffset`: Sets the format for the filename to be by week. This week will become the 0th week