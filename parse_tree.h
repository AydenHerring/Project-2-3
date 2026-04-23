#ifndef PARSE_TREE_H
#define PARSE_TREE_H

#include <unordered_map>
#include <vector>
#include <utility>
#include "tree_node.h"
#include <string>
#include <iostream>

class ParseTree {
public:
    std::unordered_map<std::string, TreeNode*> nodes;

    // Holds (childName, parentName) pairs where the parent did not exist yet
    // when the child was declared. Resolved in printTree before printing.
    std::vector<std::pair<std::string, std::string>> deferredChildren;

    void buildNode(const std::string& name, int weight, const std::string& parent) {
        TreeNode* node = new TreeNode(name, weight);
        nodes[name] = node;

        if (!parent.empty()) {
            if (nodes.count(parent)) {
                nodes[parent]->addChild(node);
            } else {
                // Parent not built yet — defer the link until printTree
                deferredChildren.push_back({name, parent});
            }
        }
    }

    void printTree(const std::string& root) {
        // Resolve any parent-child relationships where the parent was declared
        // after the child (e.g. isachildof references a not-yet-built node).
        for (auto& p : deferredChildren) {
            if (nodes.count(p.first) && nodes.count(p.second))
                nodes[p.second]->addChild(nodes[p.first]);
        }
        deferredChildren.clear();

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
