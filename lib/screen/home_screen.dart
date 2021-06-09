import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:gerenciamento_loja_upis/blocs/orders_bloc.dart';
import 'package:gerenciamento_loja_upis/blocs/user_bloc.dart';
import 'package:gerenciamento_loja_upis/tabs/orders_tab.dart';
import 'package:gerenciamento_loja_upis/tabs/products_tab.dart';
import 'package:gerenciamento_loja_upis/tabs/users_tab.dart';
import 'package:gerenciamento_loja_upis/widgets/edit_category_dialog.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController _pageController;
  int _pageNumber = 0;

  UserBloc _userBloc;
  OrdersBloc _ordersBloc;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _userBloc = UserBloc();
    _ordersBloc = OrdersBloc();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      body: SafeArea(
        child: BlocProvider(
          blocs: [Bloc((i) => _userBloc), Bloc((i) => _ordersBloc)],
          dependencies: [],
          child: PageView(
            children: [
              UsersTab(),
              OrdersTab(),
              ProductsTab(),
            ],
            controller: _pageController,
            /*onPageChanged: (selectedPageNumber) {
              setState(() {
                _pageNumber = selectedPageNumber;
              });
            },*/
            onPageChanged: (selectedPageNumber) =>
                setState(() => _pageNumber = selectedPageNumber),
          ),
        ),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.pinkAccent, // background color
          primaryColor: Colors.white, // icons color
          textTheme: Theme.of(context)
              .textTheme
              .copyWith(caption: TextStyle(color: Colors.white)),
        ),
        child: BottomNavigationBar(
          currentIndex: _pageNumber,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Clientes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Pedidos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Produtos',
            ),
          ],
          onTap: (pageNumber) {
            _pageController.animateToPage(pageNumber,
                duration: Duration(milliseconds: 500), curve: Curves.ease);
          },
        ),
      ),
      floatingActionButton: _buildFloatin(),
    );
  }

  Widget _buildFloatin() {
    switch (_pageNumber) {
      case 0:
        return null;
      case 1:
        return SpeedDial(
          child: Icon(Icons.sort),
          backgroundColor: Colors.pinkAccent,
          overlayOpacity: 0.4,
          overlayColor: Colors.black,
          children: [
            SpeedDialChild(
                child: Icon(
                  Icons.arrow_downward,
                  color: Colors.pinkAccent,
                ),
                backgroundColor: Colors.white,
                label: "Concluidos Abaixo",
                labelStyle: TextStyle(fontSize: 14),
                onTap: () {
                  _ordersBloc.setOrderCriteria(SortCriteria.READY_LAST);
                }),
            SpeedDialChild(
                child: Icon(
                  Icons.arrow_upward,
                  color: Colors.pinkAccent,
                ),
                backgroundColor: Colors.white,
                label: "Concluidos Acima",
                labelStyle: TextStyle(fontSize: 14),
                onTap: () {
                  _ordersBloc.setOrderCriteria(SortCriteria.READY_FIRST);
                })
          ],
        );
      case 2:
        return FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Colors.pinkAccent,
          onPressed: (){
            showDialog(context: context,
                builder: (context) => EditCategoryDialog()
            );
          },
        );
    }
  }
}
