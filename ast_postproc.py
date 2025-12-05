#!/usr/bin/env python
# -*- coding: utf-8 -*-

import re
import sys
from typing import Optional

NT_STYLES = {  # Стили нетерминалов (заливка узла + цвет ребра)
    # Структура
    "START": ("lightblue", "steelblue4"),
    "ROOT": ("lightblue", "steelblue4"),
    "HEADER": ("lightblue", "steelblue4"),
    "MAIN": ("lightblue", "steelblue4"),

    # Нетерминалы-обёртки
    "BLOCK_LISTS": ("lightcoral", "firebrick4"),
    "BLOCK_FOR": ("lightcoral", "firebrick4"),
    "BLOCK_PRINTS": ("lightcoral", "firebrick4"),
    "BLOCK_STRINGS": ("lightcoral", "firebrick4"),
    "BLOCK_COND": ("lightcoral", "firebrick4"),
    "BLOCK_WHILE": ("lightcoral", "firebrick4"),
    "BLOCK_FOR_CONTINUE": ("lightcoral", "firebrick4"),
    "BLOCK_CALLS": ("lightcoral", "firebrick4"),
    "BLOCK_WORDS": ("lightcoral", "firebrick4"),

    # Объявления и функции
    "CONST_PI": ("gold", "goldenrod4"),
    "FUNC_DECL": ("gold", "goldenrod4"),
    "FUNC_CIRCLE": ("gold", "goldenrod4"),
    "FUNC_FACT": ("gold", "goldenrod4"),

    # Выражения
    "TERM": ("palegreen", "green4"),
    "EXPR": ("palegreen", "green4"),
    "ASSIGNMENT": ("palegreen", "green4"),
    "TEXT_ASSIGN": ("palegreen", "green4"),
    "LENGTH_ASSIGN": ("palegreen", "green4"),
    "APPEND_CALL": ("palegreen", "green4"),

    # Эпсилон-типы
    "T_INT": ("lightgoldenrod", "goldenrod3"),
    "T_FLOAT": ("lightgoldenrod", "goldenrod3"),
    "T_NONE": ("lightgoldenrod", "goldenrod3"),

    # Коллекции
    "LIST_NUMBERS": ("plum", "purple4"),
    "LIST_SQUARES": ("plum", "purple4"),
    "LIST_VALUES": ("plum", "purple4"),
    "STR_LIST_VALUES": ("plum", "purple4"),
    "WORDS_LIST": ("plum", "purple4"),

    # Циклы
    "FOR_HEADER": ("orange", "darkorange3"),
    "LOOP_BODY": ("orange", "darkorange3"),

    # Условия
    "IF_PART": ("lightsalmon", "salmon4"),
    "ELIF_PART": ("lightsalmon", "salmon4"),
    "ELSE_PART": ("lightsalmon", "salmon4"),

    # Строки, вывод
    "PRINT_STMT": ("lightcyan", "cadetblue4"),
    "PRINT_IN_LOOP": ("lightcyan", "cadetblue4"),
    "PRINT_FUNC_CALL": ("lightcyan", "cadetblue4"),
    "PRINT_JOIN_ALL": ("lightcyan", "cadetblue4"),
    "PRINT_JOIN_REVERSED": ("lightcyan", "cadetblue4"),
}

FONT_FAMILY_NAME = "Segoe UI"

DEFAULT_NODE_FILL = "lightgrey"
DEFAULT_NODE_EDGE = "grey40"
DEFAULT_TERM_EDGE_COLOR = "grey40"

node_re = re.compile(r'^\s*(\d+)\s+\[label="([^"]*)"\]')
label_re = re.compile(r'label="([^"]+)"')


def extract_lhs_nonterminal(label: str) -> Optional[str]:
    parts = label.split(r"\n", 1)
    if len(parts) < 2:
        return None
    first_item = parts[1]
    if "->" not in first_item:
        return None
    lhs = first_item.split("->", 1)[0].strip()
    return lhs or None


def main():
    for raw_line in sys.stdin:
        line = raw_line

        # Вершины
        m = node_re.match(line)
        if m:
            state_id, full_label = m.groups()
            lhs = extract_lhs_nonterminal(full_label)

            node_fill, node_edge = NT_STYLES.get(
                lhs,
                (DEFAULT_NODE_FILL, DEFAULT_NODE_EDGE),
            )

            short_label = f"{state_id}\\n{lhs}" if lhs else state_id

            new = (
                f'  {state_id} [label="{short_label}", '
                f'style=filled, fillcolor="{node_fill}", '
                f'color="{node_edge}", '
                f'fontcolor="black", fontname="{FONT_FAMILY_NAME}"]\n'
            )
            sys.stdout.write(new)
            continue

        # Рёбра
        if "->" in line and 'label="' in line:
            lm = label_re.search(line)
            if lm:
                sym = lm.group(1)

                edge_color = None
                # Нетерминал — цвет из словаря
                if sym in NT_STYLES:
                    edge_color = NT_STYLES[sym][1]
                # Терминал (верхний регистр) — общий тёмный цвет
                elif sym.isupper():
                    edge_color = DEFAULT_TERM_EDGE_COLOR

                if edge_color and "color=" not in line:
                    line = line.rstrip("\n")
                    extra = (
                        f', color="{edge_color}", '
                        f'penwidth=2, fontcolor="black", '
                        f'fontname="{FONT_FAMILY_NAME}"'
                    )
                    if line.endswith("]"):
                        line = line[:-1] + extra + "]\n"
                    else:
                        line += extra + "\n"

        sys.stdout.write(line)


if __name__ == "__main__":
    main()
