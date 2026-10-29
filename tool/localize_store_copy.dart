// Uses the analyzer dev dependency. Dry-run prints a reviewable list;
// --apply performs the AST edits.
import 'dart:convert';
import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class CopyVisitor extends RecursiveAstVisitor<void> {
  final List<SimpleStringLiteral> strings = [];
  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    if (!RegExp(r'[\u0600-\u06ff]').hasMatch(node.value)) return;
    AstNode? parent = node.parent;
    var eligible = false;
    while (parent != null) {
      if (parent is AssignmentExpression &&
          (parent.leftHandSide.toSource() == 'message' ||
              parent.leftHandSide.toSource().endsWith('Message'))) {
        eligible = true;
        break;
      }
      if (parent is MethodInvocation && parent.methodName.name == '_label') {
        return;
      }
      if (parent is NamedExpression &&
          const {
            'label',
            'title',
            'subtitle',
            'hintText',
            'labelText',
            'message',
            'actionLabel',
            'tooltip',
            'text',
            'validator',
          }.contains(parent.name.label.name)) {
        eligible = true;
        break;
      }
      if (parent is InstanceCreationExpression &&
          parent.constructorName.type.toSource() == 'Text') {
        eligible = true;
        break;
      }
      if (parent is MethodInvocation &&
          parent.methodName.name == '_decoration') {
        eligible = true;
        break;
      }
      if (parent is MethodInvocation &&
          const {
            'Text',
            '_tile',
            'showCustomSnackBar',
          }.contains(parent.methodName.name)) {
        eligible = true;
        break;
      }
      if (parent is BlockFunctionBody) break;
      parent = parent.parent;
    }
    if (eligible &&
        node.parent is! MethodInvocation &&
        node.parent is! PropertyAccess) {
      strings.add(node);
    }
  }
}

void main(List<String> arguments) {
  final apply = arguments.contains('--apply');
  final paths = arguments.where((argument) => argument != '--apply').toList();
  final copy = <String>{};
  for (final path in paths) {
    final file = File(path);
    final source = file.readAsStringSync();
    final visitor = CopyVisitor();
    parseString(content: source, path: path).unit.accept(visitor);
    final edits = <int, ({int end, String replacement})>{};
    for (final node in visitor.strings) {
      copy.add(node.value);
      edits[node.end] = (end: node.end, replacement: '.tr');
      AstNode? ancestor = node.parent;
      while (ancestor != null) {
        if (ancestor is InstanceCreationExpression &&
            ancestor.keyword?.lexeme == 'const') {
          final token = ancestor.keyword!;
          edits[token.offset] = (end: token.end, replacement: '');
        } else if (ancestor is ListLiteral && ancestor.constKeyword != null) {
          final token = ancestor.constKeyword!;
          edits[token.offset] = (end: token.end, replacement: '');
        } else if (ancestor is SetOrMapLiteral &&
            ancestor.constKeyword != null) {
          final token = ancestor.constKeyword!;
          edits[token.offset] = (end: token.end, replacement: '');
        }
        ancestor = ancestor.parent;
      }
    }
    if (apply && edits.isNotEmpty) {
      var updated = source;
      for (final offset
          in edits.keys.toList()..sort((a, b) => b.compareTo(a))) {
        final edit = edits[offset]!;
        updated = updated.replaceRange(offset, edit.end, edit.replacement);
      }
      if (!updated.contains("import 'package:get/get.dart';")) {
        updated = "import 'package:get/get.dart';\n$updated";
      }
      file.writeAsStringSync(updated);
    }
  }
  stdout.writeln(
    const JsonEncoder.withIndent('  ').convert(copy.toList()..sort()),
  );
}
