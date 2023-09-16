import tkinter
import tkinter.font


def list_monospace_fonts():
    tkinter.Tk()
    fonts = [tkinter.font.Font(family=f) for f in tkinter.font.families()]
    monospace = [f.actual("family") for f in fonts if f.metrics("fixed")]
    print(",".join([f"'{f}'" for f in sorted(monospace)]))

def main():
    list_monospace_fonts()

if __name__ == '__main__':
    main()
