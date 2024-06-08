import 'package:flutter/material.dart';

import 'alert_messenger.dart';

void main() => runApp(const AlertPriorityApp());

class AlertPriorityApp extends StatefulWidget {
  const AlertPriorityApp({super.key});

  @override
  State<AlertPriorityApp> createState() => _AlertPriorityAppState();
}

class _AlertPriorityAppState extends State<AlertPriorityApp> {
  final AlertsController _alertsController = AlertsController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Priority App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        iconTheme: const IconThemeData(size: 16.0, color: Colors.white),
        elevatedButtonTheme: const ElevatedButtonThemeData(
          style: ButtonStyle(
            minimumSize: WidgetStatePropertyAll(
              Size(110, 40),
            ),
          ),
        ),
      ),
      home: AlertMessenger(
        notifier: _alertsController.notifier,
        child: Builder(
          builder: (context) {
            return Scaffold(
              backgroundColor: Colors.grey[200],
              appBar: AppBar(
                title: const Text('Alerts'),
                centerTitle: true,
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: ValueListenableBuilder(
                          valueListenable: _alertsController.notifier,
                          builder: (context, value, child) {
                            return Text(
                              value?.child ?? 'No alert',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 16.0,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    _alertsController.showAlert(
                                      AlertWidgetDTO(
                                        backgroundColor: Colors.red,
                                        leading: const Icon(Icons.error),
                                        priority: AlertPriority.error,
                                        child: 'Oops, ocorreu um erro. Pedimos desculpas.',
                                      ),
                                    );
                                  },
                                  style: const ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(Colors.red),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(Icons.error),
                                      SizedBox(width: 4.0),
                                      Text('Error'),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _alertsController.showAlert(
                                      AlertWidgetDTO(
                                        backgroundColor: Colors.amber,
                                        leading: const Icon(Icons.warning),
                                        priority: AlertPriority.warning,
                                        child: 'Atenção! Você foi avisado.',
                                      ),
                                    );
                                  },
                                  style: const ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(Colors.amber),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(Icons.warning_outlined),
                                      SizedBox(width: 4.0),
                                      Text('Warning'),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _alertsController.showAlert(
                                      AlertWidgetDTO(
                                        backgroundColor: Colors.green,
                                        leading: const Icon(Icons.info),
                                        priority: AlertPriority.info,
                                        child: 'Este é um aplicativo escrito em Flutter.',
                                      ),
                                    );
                                  },
                                  style: const ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(Colors.lightGreen),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(Icons.info_outline),
                                      SizedBox(width: 4.0),
                                      Text('Info'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                                vertical: 16.0,
                              ),
                              child: ElevatedButton(
                                onPressed: _alertsController.hideAlert,
                                child: const Text('Hide alert'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _alertsController.dispose();
    super.dispose();
  }
}

class AlertsController {
  final ValueNotifier<AlertWidgetDTO?> notifier = ValueNotifier(null);
  final List<AlertWidgetDTO> alerts = [];

  AlertWidgetDTO? get firstAlert => alerts.isNotEmpty ? alerts.first : null;

  void showAlert(AlertWidgetDTO value) {
    if (alerts.contains(value)) return;
    alerts.add(value);

    alerts.sort((a, b) => a.priority.index.compareTo(b.priority.index));
    notifier.value = firstAlert;
  }

  void hideAlert() {
    if (alerts.isNotEmpty) {
      alerts.removeAt(0);
    }
    notifier.value = firstAlert;
  }

  void dispose() {
    notifier.dispose();
  }
}
