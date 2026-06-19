#include <graphics.h>

// getch() comes from here
#include <conio.h>

int main() {
    initwindow(640, 480, "shapes");
    cleardevice();

    // Draw a line
    line(100, 100, 200, 200);

    // Draw a rectangle
    rectangle(250, 150, 350, 250);

    // Draw a circle
    circle(500, 200, 50);

    // old DOS "wait for key", which keeps the window open
    getch();

    closegraph();
    return 0;
} 