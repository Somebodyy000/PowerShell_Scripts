#include <iostream>
#include <fstream>
#include <string>

void PrintAsciiArt() {
    std::cout << "  _____   ____  __  __ ______    _____  _    _  _______  _    _ _____   _______ " << std::endl;
    std::cout << " / ____| / __ \\|  \\/  |  ____|  |  __ || |  | ||__   __|| |  | |  __ \\ |   ____|" << std::endl;
    std::cout << "| (___  | |  | | \\  / | |__     | |__  | |  | |   | |   | |  | | |__) ||  |__   " << std::endl;
    std::cout << " \\___ \\ | |  | | |\\/| |  __|    |  __| | |  | |   | |   | |  | |  _  / |   __|  " << std::endl;
    std::cout << " ____) || |__| | |  | | |____   | |    | |__| |   | |   | |__| | | \\ \\ |  |____ " << std::endl;
    std::cout << "|_____/  \\____/|_|  |_|______|  |_|    |______|   |_|   |______|_|  \\_\\|_______|" << std::endl;
    std::cout << std::endl;
    std::cout << "                          Created by S.F." << std::endl;
}

void CreateFile(const std::string& filePath, const std::string& text) {
    std::ofstream file(filePath);
    
    if (file.is_open()) {
        file << text;
        file.close();
        std::cout << filePath << std::endl;
    } else {
        std::cerr << "Error opening file." << std::endl;
    }
}

int main() {
    PrintAsciiArt();
    
    std::string text = "Long ass text here.";
    
    std::string infoFilePath = "stolen_info.txt";

    if (remove(infoFilePath.c_str()) != 0) {
        std::cout << "No existing file to delete or file deletion failed." << std::endl;
    }

    CreateFile(infoFilePath, text);

    system(infoFilePath.c_str());

    return 0;
}
