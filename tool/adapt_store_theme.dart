import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class ThemeVisitor extends RecursiveAstVisitor<void> {
  final Map<int, ({int end, String replacement})> edits = {};
  bool hasContext(AstNode node) {
    AstNode? parent = node.parent;
    while (parent != null) {
      if (parent is MethodDeclaration &&
          parent.parameters?.parameters.any(
                (parameter) =>
                    RegExp(r'\bcontext\b').hasMatch(parameter.toSource()),
              ) ==
              true) {
        return true;
      }
      if (parent is FunctionExpression &&
          parent.parameters?.parameters.any(
                (parameter) =>
                    RegExp(r'\bcontext\b').hasMatch(parameter.toSource()),
              ) ==
              true) {
        return true;
      }
      if (parent is FunctionDeclaration &&
          parent.functionExpression.parameters?.parameters.any(
                (parameter) =>
                    RegExp(r'\bcontext\b').hasMatch(parameter.toSource()),
              ) ==
              true) {
        return true;
      }
      parent = parent.parent;
    }
    return false;
  }

  void removeConstAncestors(AstNode node) {
    AstNode? ancestor = node.parent;
    while (ancestor != null) {
      if (ancestor is InstanceCreationExpression &&
          ancestor.keyword?.lexeme == 'const') {
        final token = ancestor.keyword!;
        edits[token.offset] = (end: token.end, replacement: '');
      } else if (ancestor is ListLiteral && ancestor.constKeyword != null) {
        final token = ancestor.constKeyword!;
        edits[token.offset] = (end: token.end, replacement: '');
      }
      ancestor = ancestor.parent;
    }
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    if (!hasContext(node)) return;
    AstNode? owner = node.parent;
    while (owner != null &&
        owner is! Statement &&
        owner is! FunctionExpression) {
      if (owner is MethodInvocation &&
          owner.target?.toSource() == 'StoreColors') {
        return;
      }
      owner = owner.parent;
    }
    final prefix = node.prefix.name;
    final member = node.identifier.name;
    if (prefix == 'StorePalette' && member == 'navy') {
      AstNode? parent = node.parent;
      while (parent != null &&
          parent is! Statement &&
          parent is! FunctionExpression) {
        final isStyle =
            parent is InstanceCreationExpression &&
            parent.constructorName.type.toSource() == 'TextStyle';
        final isCopy =
            parent is MethodInvocation && parent.methodName.name == 'copyWith';
        if (isStyle || isCopy) {
          edits[node.offset] = (
            end: node.end,
            replacement: 'StoreColors.resolve(context, ${node.toSource()})',
          );
          removeConstAncestors(node);
          return;
        }
        parent = parent.parent;
      }
    }
    if (prefix == 'StorePalette' &&
        const {
          'surface',
          'background',
          'textPrimary',
          'textSecondary',
          'textDisabled',
          'border',
          'lightPurple',
          'derivedWarningSurface',
          'derivedErrorSurface',
          'derivedSuccessSurface',
          'derivedInfoSurface',
        }.contains(member)) {
      edits[node.offset] = (
        end: node.end,
        replacement: 'StoreColors.resolve(context, ${node.toSource()})',
      );
      removeConstAncestors(node);
    } else if (prefix == 'StoreTypography' &&
        const {
          'display',
          'headline',
          'title',
          'body',
          'bodyMedium',
          'label',
          'caption',
        }.contains(member)) {
      edits[node.offset] = (
        end: node.end,
        replacement: 'StoreColors.text(context, ${node.toSource()})',
      );
      removeConstAncestors(node);
    }
  }
}

void main(List<String> arguments) {
  final apply = arguments.contains('--apply');
  final paths = arguments
      .where((argument) => argument != '--apply')
      .expand(
        (path) =>
            Directory(path).existsSync()
                ? Directory(path)
                    .listSync(recursive: true)
                    .whereType<File>()
                    .where((file) => file.path.endsWith('.dart'))
                    .map((file) => file.path)
                : [path],
      );
  for (final path in paths) {
    final file = File(path);
    final source = file.readAsStringSync();
    final visitor = ThemeVisitor();
    parseString(content: source, path: path).unit.accept(visitor);
    if (visitor.edits.isEmpty) continue;
    stdout.writeln('$path: ${visitor.edits.length} contextual theme edits');
    if (!apply) continue;
    var updated = source;
    for (final offset
        in visitor.edits.keys.toList()..sort((a, b) => b.compareTo(a))) {
      final edit = visitor.edits[offset]!;
      updated = updated.replaceRange(offset, edit.end, edit.replacement);
    }
    if (!updated.contains(
      "import 'package:doctor_bike/core/theme/store_colors.dart';",
    )) {
      updated =
          "import 'package:doctor_bike/core/theme/store_colors.dart';\n$updated";
    }
    file.writeAsStringSync(updated);
  }
}
