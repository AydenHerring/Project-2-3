#ifndef PARSE_TREE_H
#define PARSE_TREE_H

#include <unordered_map>
#include "tree_node.h"
#include <string>
#include <iostream>

class ParseTree {
public:
    std::unordered_map<std::string, TreeNode*> nodes;

    void buildNode(const std::string& name, int weight, const std::string& parent) {
        TreeNode* node = new TreeNode(name, weight);
        nodes[name] = node;

        if (!parent.empty() && nodes.count(parent)) {
            nodes[parent]->addChild(node);
        }
    }

    void printTree(const std::string& root) {
        if (nodes.count(root)) {
            printHelper(nodes[root]);
            std::cout << std::endl;
        }
    }

private:
    void printHelper(TreeNode* node) {
        std::cout << node->name;
        if (!node->children.empty()) {
            std::cout << " [ ";
            for (size_t i = 0; i < node->children.size(); i++) {
                printHelper(node->children[i]);
                if (i != node->children.size() - 1) std::cout << ", ";
            }
            std::cout << " ]";
        }
    }
};

#endif
