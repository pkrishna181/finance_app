#include "llama-grammar.h"

#include <cstdio>

extern "C" int arth_grammar_rule_count(const char * grammar_str) {
    if (grammar_str == NULL || grammar_str[0] == '\0') {
        return 0;
    }

    llama_grammar_parser parser;
    if (!parser.parse(grammar_str) || parser.rules.empty()) {
        return 0;
    }

    return static_cast<int>(parser.rules.size());
}
