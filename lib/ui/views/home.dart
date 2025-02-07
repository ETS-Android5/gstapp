import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tassist/core/models/company.dart';

import 'package:tassist/core/services/database.dart';

import 'package:tassist/theme/theme.dart';

import 'package:tassist/ui/shared/drawer.dart';
import 'package:tassist/ui/shared/headernav.dart';
import 'package:tassist/ui/views/accountspayablescreen.dart';
import 'package:tassist/ui/views/accountsreceivables.dart';

import 'package:tassist/ui/views/ledgerinput.dart';
import 'package:tassist/ui/views/ledgerscreen.dart';
import 'package:tassist/ui/views/settingsscreen.dart';
import 'package:tassist/ui/views/stockscreen.dart';
import 'package:tassist/ui/views/vouchers.dart';
import 'package:tassist/core/services/string_format.dart';

var formatter = new DateFormat('dd-MM-yyyy');

_formatDate(DateTime date) {
  if (date != null) {
    return formatter.format(date);
  } else {
    return 'NA';
  }
}

class HomeDashboardScreen extends StatefulWidget {
  HomeDashboardScreen({Key key, this.userId}) : super(key: key);

  final String userId;

  @override
  _HomeDashboardScreenState createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  String timePeriod = 'Everything';

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    final GlobalKey<ScaffoldState> _drawerKey = new GlobalKey<ScaffoldState>();

    return MultiProvider(
        providers: [
          StreamProvider<DocumentSnapshot>.value(
            value:
                DatabaseService().metricCollection.doc(user?.uid).snapshots(),
            initialData: null,
          ),
        ],
        child: WillPopScope(
            onWillPop: () async => false,
            child: Scaffold(
              key: _drawerKey,
              appBar: headerNav(_drawerKey),
              drawer: tassistDrawer(context),
              body: SafeArea(
                child: ListView(
                  children: <Widget>[
                    //StatusBar(),
                    // tallyconnection(tallyconnected),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Text(
                        'Tally Dashboard',
                        style: secondaryListTitle,
                      ),
                    ),
                    Container(
                      child: DashboardCard(
                        timePeriod: timePeriod,
                      ),
                      margin: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
                      // decoration: myBoxDecorationTopBorder()
                    ),
                    Container(
                      child: DashboardCard2(
                        timePeriod: timePeriod,
                      ),
                      margin: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
                      // decoration: myBoxDecorationTopBorder()
                    ),
                    Container(
                      child: DashboardCard3(
                        timePeriod: timePeriod,
                      ),
                      margin: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
                      // decoration: myBoxDecorationTopBorder()
                    ),
                    Padding(
                      padding: spacer.all.xs,
                      child: Text(
                        'View / जानकारी देखें',
                        style: secondaryListTitle,
                      ),
                    ),
                    Padding(
                      padding: spacer.x.xs,
                      child: FittedBox(
                        child: Row(
                          children: <Widget>[
                            ActionButton(Icon(FontAwesomeIcons.listAlt),
                                LedgerScreen(), 'Parties', 'पार्टी'),
                            ActionButton(Icon(FontAwesomeIcons.fileInvoice),
                                VouchersHome(), 'Vouchers', 'वाउचर'),
                            ActionButton(Icon(FontAwesomeIcons.warehouse),
                                StockScreen(), 'Stock', 'स्टॉक'),
                            ActionButton(Icon(Icons.settings), SettingsScreen(),
                                'Settings', 'सैटिंग्स'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton.extended(
                  icon: Icon(FontAwesomeIcons.fileInvoice),
                  label: Text('Invoice बनाएँ'),
                  backgroundColor: TassistMenuBg,
                  onPressed: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => LedgerInputScreen(),
                    ));
                  }),
            )));
  }
}

class StatusBar extends StatefulWidget {
  @override
  _StatusBarState createState() => _StatusBarState();
}

class _StatusBarState extends State<StatusBar> {
  @override
  Widget build(BuildContext context) {
    final companyData = Provider.of<Company>(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 5.0),
      child: Row(
        children: <Widget>[
          Text(
            'Synced: ',
            style: TextStyle(fontSize: 12, color: TassistInfoGrey),
          ),
          Text(
            _formatDate(companyData.lastSyncedAt),
            style: TextStyle(fontSize: 12, color: TassistMenuBg),
          ),
          Expanded(child: SizedBox(width: 20)),
          Text(
            'Last Entry: ',
            style: TextStyle(fontSize: 12, color: TassistInfoGrey),
          ),
          Text(
            _formatDate(companyData.lastEntryDate),
            style: TextStyle(fontSize: 12, color: TassistMenuBg),
          )
        ],
      ),
      color: TassistBgLightPurple,
      width: MediaQuery.of(context).size.width,
      height: 30,
    );
  }
}

class DashboardCard extends StatefulWidget {
  final String timePeriod;
  DashboardCard({this.timePeriod});

  @override
  _DashboardCardState createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> {
  @override
  Widget build(BuildContext context) {
    final snapshot = Provider.of<DocumentSnapshot>(context);
    var userDocument;
    // print("hey");
    // print(snapshot.data());
    //print(snapshot[widget.timePeriod]);
    if (widget.timePeriod == 'Everything') {
      userDocument = snapshot?.data();
    } else {
      userDocument = snapshot[widget.timePeriod];
    }

    if (userDocument != null) {
      return FittedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Card(
              elevation: 5,
              child: Container(
                width: MediaQuery.of(context).size.width / 2.2,
                height: 70,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => VouchersHome(),
                    ));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          formatIndianCurrency(
                                  userDocument['total_sales'].toString()) ??
                              '',
                          style: Theme.of(context).textTheme.bodyText2.copyWith(
                              color: TassistMainText,
                              fontSize: 18,
                              fontWeight: FontWeight.normal),
                        ),
                        Text(
                          'Sales सेल्स ',
                          style:
                              secondaryListDisc.copyWith(color: TassistPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 20.0,
            ),
            Card(
                elevation: 5,
                child: Container(
                  width: MediaQuery.of(context).size.width / 2.2,
                  height: 70,
                  child: InkWell(
                      onTap: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => VouchersHome(),
                        ));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              // formatIndianCurrency(
                              userDocument['net_profit'].toString() ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  .copyWith(
                                      color: TassistMainText,
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal),
                            ),
                            Text(
                              'Net Profit लाभ',
                              style: secondaryListDisc.copyWith(
                                  color: TassistPrimary),
                            ),
                          ],
                        ),
                      )),
                ))
            // SimpleTimeSeriesChart.withSampleData(),
          ],
        ),
      );
    } else {
      return Container(
        child: Center(
          child: Text('Loading...'),
        ),
      );
    }
  }
}

class DashboardCard2 extends StatefulWidget {
  final String timePeriod;
  DashboardCard2({this.timePeriod});

  @override
  _DashboardCard2State createState() => _DashboardCard2State();
}

class _DashboardCard2State extends State<DashboardCard2> {
  @override
  Widget build(BuildContext context) {
    final snapshot = Provider.of<DocumentSnapshot>(context);
    var userDocument;
    if (widget.timePeriod == 'Everything') {
      userDocument = snapshot?.data();
    } else {
      userDocument = snapshot[widget.timePeriod];
    }

    if (userDocument != null) {
      return FittedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Card(
              elevation: 5,
              child: Container(
                width: MediaQuery.of(context).size.width / 2.2,
                height: 70,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => AccountsReceivableScreen(),
                    ));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          formatIndianCurrency(
                                  userDocument['out_actual_rec'].toString()) ??
                              '',
                          style: Theme.of(context).textTheme.bodyText2.copyWith(
                              color: TassistMainText,
                              fontSize: 18,
                              fontWeight: FontWeight.normal),
                        ),
                        Text(
                          'Receivables लेन ',
                          style:
                              secondaryListDisc.copyWith(color: TassistPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 20.0,
            ),
            Card(
                elevation: 5,
                child: Container(
                  width: MediaQuery.of(context).size.width / 2.2,
                  height: 70,
                  child: InkWell(
                      onTap: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => AccountsPayableScreen(),
                        ));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              formatIndianCurrency(
                                      userDocument['out_actual_pay']
                                          .toString()) ??
                                  '',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  .copyWith(
                                      color: TassistMainText,
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal),
                            ),
                            Text(
                              'Payables देन',
                              style: secondaryListDisc.copyWith(
                                  color: TassistPrimary),
                            ),
                          ],
                        ),
                      )),
                ))
            // SimpleTimeSeriesChart.withSampleData(),
          ],
        ),
      );
    } else {
      return Container(
        child: Center(
          child: Text('Loading...'),
        ),
      );
    }
  }
}

class DashboardCard3 extends StatefulWidget {
  final String timePeriod;
  DashboardCard3({this.timePeriod});

  @override
  _DashboardCard3State createState() => _DashboardCard3State();
}

class _DashboardCard3State extends State<DashboardCard3> {
  @override
  Widget build(BuildContext context) {
    final snapshot = Provider.of<DocumentSnapshot>(context);
    var userDocument;
    if (widget.timePeriod == 'Everything') {
      userDocument = snapshot?.data();
    } else {
      userDocument = snapshot[widget.timePeriod];
    }

    if (userDocument != null) {
      return FittedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Card(
              elevation: 5,
              child: Container(
                width: MediaQuery.of(context).size.width / 2.2,
                height: 70,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => AccountsReceivableScreen(),
                    ));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          // formatIndianCurrency(
                          userDocument['cash_in_hand'].toString() ?? '',
                          style: Theme.of(context).textTheme.bodyText2.copyWith(
                              color: TassistMainText,
                              fontSize: 18,
                              fontWeight: FontWeight.normal),
                        ),
                        Text(
                          'Cash in Hand नकद',
                          style:
                              secondaryListDisc.copyWith(color: TassistPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 20.0,
            ),
            Card(
                elevation: 5,
                child: Container(
                  width: MediaQuery.of(context).size.width / 2.2,
                  height: 70,
                  child: InkWell(
                      onTap: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => AccountsPayableScreen(),
                        ));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              // formatIndianCurrency(
                              userDocument['cash_in_bank'].toString() ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  .copyWith(
                                      color: TassistMainText,
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal),
                            ),
                            Text(
                              'Cash in Bank बैंक',
                              style: secondaryListDisc.copyWith(
                                  color: TassistPrimary),
                            ),
                          ],
                        ),
                      )),
                ))
            // SimpleTimeSeriesChart.withSampleData(),
          ],
        ),
      );
    } else {
      return Container(
        child: Center(
          child: Text('Loading...'),
        ),
      );
    }
  }
}

class ActionButton extends StatelessWidget {
  final Icon icon;
  final Widget widget;
  final String title;
  final String hindiTitle;

  ActionButton(this.icon, this.widget, this.title, this.hindiTitle);

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 3,
        child: Container(
          padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
          width: MediaQuery.of(context).size.width / 4.5,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                IconButton(
                    icon: icon,
                    iconSize: 30,
                    padding: const EdgeInsets.all(4.0),
                    color: Colors.grey[800],
                    onPressed: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => widget,
                      ));
                    }),
                Text(
                  title,
                  style: secondaryListDisc.copyWith(
                      fontSize: 14, color: TassistPrimary),
                ),
                Text(
                  hindiTitle,
                  style: secondaryListDisc.copyWith(
                      fontSize: 14, color: TassistPrimary),
                )
              ]),
        ));
  }
}
