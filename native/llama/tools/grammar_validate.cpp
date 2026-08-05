#include "llama-grammar.h"

#include <cstdio>
#include <fstream>
#include <sstream>
#include <string>

int main(int argc, char ** argv) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <grammar.gbnf>\n", argv[0]);
        return 2;
    }

    std::ifstream in(argv[1]);
    if (!in.is_open()) {
        fprintf(stderr, "FAIL open: %s\n", argv[1]);
        return 2;
    }

    std::stringstream buffer;
    buffer << in.rdbuf();
    const std::string grammar = buffer.str();

    llama_grammar_parser parser;
    if (!parser.parse(grammar.c_str()) || parser.rules.empty()) {
        fprintf(stderr, "FAIL parse: %s (llama.cpp grammar parser rejected input)\n", argv[1]);
        return 1;
    }

    printf("OK %s (%zu rules)\n", argv[1], parser.rules.size());
    return 0;
}
