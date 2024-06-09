import 'package:flutter/material.dart';

class Alert extends StatelessWidget {
  const Alert({
    super.key,
    required this.alertDTO,
  });

  final AlertWidgetDTO alertDTO;

  @override
  Widget build(BuildContext context) {
    final statusbarHeight = MediaQuery.of(context).padding.top;
    return Material(
      child: Ink(
        color: alertDTO.backgroundColor,
        height: kAlertHeight + statusbarHeight,
        child: Column(
          children: [
            SizedBox(height: statusbarHeight),
            Expanded(
              child: Row(
                children: [
                  const SizedBox(width: 28),
                  IconTheme(
                    data: const IconThemeData(
                      color: Colors.white,
                      size: 36,
                    ),
                    child: Icon(alertDTO.leading),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DefaultTextStyle(
                      style: const TextStyle(color: Colors.white),
                      child: Text(
                        alertDTO.child,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 28),
          ],
        ),
      ),
    );
  }

  
}

class AlertMessenger extends StatefulWidget {
  const AlertMessenger({
    super.key,
    required this.child,
    required this.notifier,
  });

  final Widget child;
  final ValueNotifier<AlertWidgetDTO?> notifier;

  @override
  State<AlertMessenger> createState() => AlertMessengerState();

  static AlertMessengerState of(BuildContext context) {
    try {
      final scope = _AlertMessengerScope.of(context);
      return scope.state;
    } catch (error) {
      throw FlutterError.fromParts(
        [
          ErrorSummary('No AlertMessenger was found in the Element tree'),
          ErrorDescription('AlertMessenger is required in order to show and hide alerts.'),
          ...context.describeMissingAncestor(expectedAncestorType: AlertMessenger),
        ],
      );
    }
  }
}

class AlertMessengerState extends State<AlertMessenger> with TickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> animation;

  AlertWidgetDTO? alertWidgetDTO;

  @override
  Widget build(BuildContext context) {
    final statusbarHeight = MediaQuery.of(context).padding.top;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final position = animation.value + kAlertHeight;
        return Stack(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          children: [
            Positioned.fill(
              top: position <= statusbarHeight ? 0 : position - statusbarHeight,
              child: _AlertMessengerScope(
                state: this,
                child: widget.child,
              ),
            ),
            Positioned(
              top: animation.value,
              left: 0,
              right: 0,
              child: alertWidgetDTO != null
                  ? Alert(alertDTO: alertWidgetDTO!)
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    widget.notifier.addListener(() async {
      final value = widget.notifier.value;
      if (value != null) {
        await hideAlert();
        showAlert(value: value);
      } else {
        hideAlert();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final alertHeight = MediaQuery.of(context).padding.top + kAlertHeight;
    animation = Tween<double>(begin: -alertHeight, end: 0.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> showAlert({required AlertWidgetDTO value}) async {
    alertWidgetDTO = value;
    await controller.forward();
  }

  Future<void> hideAlert() async {
    await controller.reverse();
  }
}

class _AlertMessengerScope extends InheritedWidget {
  const _AlertMessengerScope({
    required this.state,
    required super.child,
  });

  final AlertMessengerState state;

  @override
  bool updateShouldNotify(_AlertMessengerScope oldWidget) => state != oldWidget.state;

  static _AlertMessengerScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_AlertMessengerScope>();
  }

  static _AlertMessengerScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'No _AlertMessengerScope found in context');
    return scope!;
  }
}

const kAlertHeight = 80.0;

enum AlertPriority {
  error(2),
  warning(1),
  info(0);

  const AlertPriority(this.value);
  final int value;
}

class AlertWidgetDTO {
  final Color backgroundColor;
  final AlertPriority priority;
  final String child;
  final IconData leading;

  AlertWidgetDTO({
    required this.backgroundColor,
    required this.priority,
    required this.child,
    required this.leading,
  });

  const AlertWidgetDTO.error({
    required this.child,
  })  : priority = AlertPriority.error,
        backgroundColor = Colors.red,
        leading = Icons.error;

  const AlertWidgetDTO.warning({
    required this.child,
  })  : priority = AlertPriority.warning,
        backgroundColor = Colors.amber,
        leading = Icons.warning;

  const AlertWidgetDTO.info({
    required this.child,
  })  : priority = AlertPriority.info,
        backgroundColor = Colors.green,
        leading = Icons.info;
}
