import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:boring_widget/boring_widget.dart';
import 'package:source_gen/source_gen.dart';

class BoringWidgetGenerator extends GeneratorForAnnotation<BoringWidget> {
  @override
  FutureOr<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    return _generateWidgetSource(element);
  }

  String _generateWidgetSource(Element element) {
    final visitor = ModelVisitor();
    element.visitChildren(visitor);
    final sourceBuilder = StringBuffer();
    // Class name
    sourceBuilder.writeln(
        "class ${visitor.className.getDisplayString(withNullability: false)}Widget extends StatelessWidget{");

    // Constructor
    sourceBuilder.write("${visitor.className.getDisplayString(withNullability: false)}Widget (");

    final parametersBuilder = StringBuffer();
    for (String parameterName in visitor.fields.keys) {
      parametersBuilder.write("this.$parameterName,");
    }
    sourceBuilder.write(parametersBuilder);
    sourceBuilder.writeln(");");
    for (String propertyName in visitor.fields.keys){
      sourceBuilder.writeln("final ${visitor.fields[propertyName].getDisplayString(withNullability: false)} $propertyName;");
    }

    sourceBuilder.writeln("@override");
    sourceBuilder.writeln("Widget build(BuildContext context) => Padding( padding: EdgeInsets.all(12),child:Column(");
    sourceBuilder.writeln("children:<Widget>[");
    final textWidgets = StringBuffer();
    for(String propertyName in visitor.fields.keys) {
      textWidgets.writeln("Text(\"$propertyName \$$propertyName\"),");
    }
    sourceBuilder.writeln(textWidgets);
    sourceBuilder.writeln("],");
    sourceBuilder.writeln("),);");
    sourceBuilder.writeln("}");

    return  sourceBuilder.toString() ;
  }
}

class ModelVisitor extends SimpleElementVisitor {
  DartType className;
  Map<String, DartType> fields = Map();

  @override
  visitConstructorElement(ConstructorElement element) {
    className = element.type.returnType;
    return super.visitConstructorElement(element);
  }

  @override
  visitFieldElement(FieldElement element) {
    fields[element.name] = element.type;

    return super.visitFieldElement(element);
  }
}
