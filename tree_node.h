#ifndef TREE_NODE_H
#define TREE_NODE_H

#include <string>
#include <vector>
#include <iostream>

class TreeNode {
public:
    std::string name;
    int weight;
    std::vector<TreeNode*> children;

    TreeNode(const std::string& n, int w) : name(n), weight(w) {}

    void addChild(TreeNode* child) {
        children.push_back(child);
    }

    void print(int indent = 0) const {
        for (int i = 0; i < indent; ++i) std::cout << "  ";
        std::cout << name << " (" << weight << ")\n";
        for (auto c : children) c->print(indent + 1);
    }

    bool isAChildOf(const std::string& parentName) const {
        for (auto c : children) {
            if (c->name == parentName || c->isAChildOf(parentName))
                return true;
        }
        return false;
    }
};

#endif