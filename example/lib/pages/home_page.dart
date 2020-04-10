import 'package:flutter/material.dart';
import 'package:markdown_widget/config/platform.dart';
import 'markdown_page.dart';
import 'edit_markdown_page.dart';

class HomePage extends StatelessWidget {

  final bool isMobile = PlatformDetector().isMobile();

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: isMobile ? AppBar(title: Text('markdown'),) : null,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            FlatButton(onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (ctx){
                  return MarkdownPage(assetsPath: 'assets/demo_en.md',);
              }));
            }, child: Text('English Markdown Demo')),
            FlatButton(onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (ctx){
                return MarkdownPage(assetsPath: 'assets/demo_zh.md');
              }));
            }, child: Text('中文 Markdown Demo')),
            FlatButton(onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (ctx){
                return EditMarkdownPage();
              }));
            }, child: Text('Edit Markdown Demo')),
          ],
        ),
      ),
    );
  }
}
