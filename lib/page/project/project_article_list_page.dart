import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wanandroid_learning_flutter/api/api_service.dart';
import 'package:wanandroid_learning_flutter/model/article_bean.dart';
import 'package:wanandroid_learning_flutter/page/web_view_page.dart';
import 'package:wanandroid_learning_flutter/res/strings.dart';
import 'package:wanandroid_learning_flutter/widget/my_circular_progress_indicator.dart';

class ProjectArticleListPage extends StatefulWidget {
  int _projectCategoryId;

  ProjectArticleListPage(int projectCategoryId) {
    this._projectCategoryId = projectCategoryId;
  }

  @override
  _ProjectArticleListPageState createState() =>
      _ProjectArticleListPageState(_projectCategoryId);
}

class _ProjectArticleListPageState extends State<ProjectArticleListPage> {
  List<Article> _articleList = List();
  int _projectCategoryId;
  int _pageNumber = 0;
  bool _isLoadAllArticles = false;

  _ProjectArticleListPageState(int projectCategoryId) {
    this._projectCategoryId = projectCategoryId;
  }

  void _getProjectArticleData(int pageNumber) async {
    ApiService().getProjectArticleData(pageNumber, _projectCategoryId,
        (ArticleBean articleBean) {
      setState(() {
        if (articleBean.data != null) {
          _isLoadAllArticles = articleBean.data.over;
          _articleList.addAll(articleBean.data.articles);
        }
        if (_isLoadAllArticles) {
          _articleList.add(null); //用于展示所有文章都以被加载
        }
      });
    });
  }

  @override
  void initState() {
    _getProjectArticleData(_pageNumber);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _articleList.length,
        itemBuilder: (context, index) {
          if (index == _articleList.length - 1) {
            //加载了所有数据后，不必再去请求服务器，这时候也不应该展示 loading, 而是展示"所有文章都已被加载"
            if (!_isLoadAllArticles) {
              _getProjectArticleData(++_pageNumber);
              return MyCircularProgressIndicator();
            } else {
              return Container(
                padding: EdgeInsets.all(5),
                alignment: Alignment.center,
                child: Text(
                  Strings.IS_LOAD_ALL_ARTICLE_CN,
                ),
              );
            }
          }

          return new GestureDetector(
            child: _projectArticleListItem(_articleList[index]),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          WebViewPage(_articleList[index].link)));
            },
          );
        },
        scrollDirection: Axis.vertical,
      ),
    );
  }

  Widget _projectArticleListItem(Article article) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: Colors.grey, offset: Offset(2.0, 2.0), blurRadius: 4.0)
          ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image(
            image: NetworkImage(article.envelopePic),
            width: 110,
            height: 200,
            alignment: Alignment.center,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10, right: 5, bottom: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    article.title,
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Container(
                      height: 130,
                      child: Text(
                        article.desc,
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
//                  Expanded(
//                    child: Text(
//                      article.desc,
//                      maxLines: 6,
//                      overflow: TextOverflow.ellipsis,
//                    ),
//                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: 5,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          article.author.isEmpty
                              ? article.shareUser
                              : article.author,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: Container(
                            child: Text(article.niceDate),
                            alignment: Alignment.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
