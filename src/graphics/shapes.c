#include <graphics.h>
#include <conio.h>

int main() {
    int gd = DETECT, gm;
    initgraph(&gd, &gm, "C:\\Turboc3\\BGI");

    // Draw a line
    line(100, 100, 200, 200);

    // Draw a rectangle
    rectangle(250, 150, 350, 250);

    // Draw a circle
    circle(500, 200, 50);

    getch();
    closegraph();
    return 0;
} 