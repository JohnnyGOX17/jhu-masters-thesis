# JHU Master Electrical Engineering Thesis


## LaTeX

This thesis LaTeX template [forked from weitzner/jhu-thesis-template](https://github.com/weitzner/jhu-thesis-template). This repo is intended to create LaTeX that complies with the JHU formatting requirements found [here](http://guides.library.jhu.edu/etd/formatting).

The file `RJournal_nogeom.sty` is used to change the color of some links and other style changes.

### Figures

Figures should be generated as such:

```tex
\begin{figure}[htbp]
  \centering
  \includegraphics[width=\columnwidth]{myfigure}
  \caption{My caption}
  \label{fig:myfig}
\end{figure}
```

Where the figure `myfigure.EXT` can be located in the directory designated by the `\graphicspath` command in the `root.tex` file.

Note that no file extension is given in the `includegraphicx` command; this makes the code maximally portable for different graphics drivers. For `pdflatex`, there are many allowable extensions, including `.pdf` and `.jpg` among others. For plain latex, you generally have to use `.eps` files. But, if you hard-code the extension in your LaTeX code, then you will not be able to switch between latex and `pdflatex`.

### To Build

#### Makefile
Simply run:
```sh
make
```
To clean the files that you won't need, run
```sh
make clean
```
