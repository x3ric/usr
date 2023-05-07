// Simple deamon to set tty colors without root

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define MAX_CMD_SIZE 512
#define MAX_COLOR_SIZE 256
#define MAX_PATH_SIZE 256
#define DELAY_SECONDS 5

int main(int argc, char *argv[]) {
    char *home = argv[1];
    char filePath[MAX_PATH_SIZE];
    snprintf(filePath, sizeof(filePath), "%s/.cache/ttywal", home);
    printf("Input file path: %s\n", filePath);
    char colors[MAX_COLOR_SIZE];
    char cmd[MAX_CMD_SIZE];
    FILE *file;
    while (1) {
        file = fopen(filePath, "r");
        if (!file) {
            perror("Error opening file");
            sleep(DELAY_SECONDS);
            continue;
        }
        fseek(file, 0, SEEK_END);
        long fileSize = ftell(file);
        if (fileSize == 0) {
            printf("Input file is empty. Waiting for data...\n");
            fclose(file);
            sleep(DELAY_SECONDS);
            continue;
        }
        rewind(file);
        if (fscanf(file, "%s", colors) == 1) {
            int cmd_length = snprintf(NULL, 0, "sudo setvtrgb %s",colors);
            if (cmd_length >= MAX_CMD_SIZE) {
                fprintf(stderr, "Command too long, skipping execution.\n");
            } else {
                snprintf(cmd, sizeof(cmd), "sudo setvtrgb %s", colors);
                printf("Executing command: %s\n", cmd);
                system(cmd);
                if (freopen(filePath, "w", file) == NULL) {
                    perror("Error clearing file");
                } else {
                    printf("Input file cleared.\n");
                }
            }
        } else {
            fprintf(stderr, "File format error. Ensure the file contains colors.\n");
        }
        fclose(file);
        sleep(DELAY_SECONDS);
    }
    return 0;
}
