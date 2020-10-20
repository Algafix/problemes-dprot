# Merkle tree implementation

## Tree generation

In order to generate the tree, execute:

```shell
bash create_merkle.sh [# of nodes]
```
This will compute all the nodes in the nodes/ folder and generate a definition file for the tree create_merkle.sh


## Add new document

Place de new document in the docs/ folder with the correct naming. Then execute:

```shell
bash add_node.sh
```

It will also update the create_merkle.sh definiton file.

## Generate proof of document

To generate the proof file for a document the command is:

```shell
bash proof_generator.sh [document_position]
```
It will generate a file with the public information of the tree and the necessary nodes to perform the validation.

## Verify a document

To verify the belonging of a node to the tree we have to execute the script:

```shell
bash proof_verifier.sh [document_position] [proof_file]
```

