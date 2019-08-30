import 'package:authpass/bloc/kdbx_bloc.dart';
import 'package:authpass/ui/common_fields.dart';
import 'package:authpass/ui/widgets/keyboard_handler.dart';
import 'package:authpass/ui/widgets/link_button.dart';
import 'package:authpass/ui/widgets/primary_button.dart';
import 'package:authpass/utils/async_utils.dart';
import 'package:authpass/utils/dialog_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_async_utils/flutter_async_utils.dart';
import 'package:kdbx/kdbx.dart';
import 'package:provider/provider.dart';

class EntryDetailsScreen extends StatefulWidget {
  const EntryDetailsScreen({Key key, @required this.entry}) : super(key: key);

  static Route<void> route({@required KdbxEntry entry}) => MaterialPageRoute(
      settings: const RouteSettings(name: '/entry'),
      builder: (context) => EntryDetailsScreen(
            entry: entry,
          ));

  final KdbxEntry entry;

  @override
  _EntryDetailsScreenState createState() => _EntryDetailsScreenState();
}

class _EntryDetailsScreenState extends State<EntryDetailsScreen> with TaskStateMixin {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry.label ?? ''),
      ),
//      floatingActionButton: FloatingActionButton(
//        child: Icon(Icons.add),
//        onPressed: () {},
//      ),
      body: Form(
        key: _formKey,
        child: EntryDetails(entry: widget.entry),
      ),
      bottomNavigationBar: Material(
        elevation: 8,
//        color: Colors.green,
        child: Container(
//          decoration: BoxDecoration(border: Border(top: BorderSide())),
          padding: const EdgeInsets.all(16) + EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          child: PrimaryButton(
            onPressed: asyncTaskCallback(() async {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                final kdbxBloc = Provider.of<KdbxBloc>(context);
                if (kdbxBloc.fileSourceForFile(widget.entry.file).supportsWrite) {
                  await kdbxBloc.saveFile(widget.entry.file);
                }
              }
            }),
            icon: Icon(Icons.save),
            child: const Text('Save'),
          ),
        ),
      ),
    );
  }
}

class EntryDetails extends StatefulWidget {
  const EntryDetails({Key key, @required this.entry}) : super(key: key);

  final KdbxEntry entry;

  @override
  _EntryDetailsState createState() => _EntryDetailsState();
}

class _EntryDetailsState extends State<EntryDetails> with StreamSubscriberMixin {
  final List<EntryField> fields = [];

  void _initTextControllers() {}

  void _initShortcutListener(KeyboardShortcutEvents events, CommonFields commonFields) {
    handleSubscription(events.shortcutEvents.listen((event) {
      if (event.type == KeyboardShortcutType.copyPassword) {
        _copyField(commonFields.password);
      } else if (event.type == KeyboardShortcutType.copyUsername) {
        _copyField(commonFields.userName);
      }
    }));
  }

  Future<void> _copyField(CommonField commonField) async {
    final value = widget.entry.getString(commonField.key);
    Scaffold.of(context).hideCurrentSnackBar();
    if (value != null && value.getText() != null) {
      await Clipboard.setData(ClipboardData(text: value.getText()));
//      await ClipboardManager.copyToClipBoard(value.getText());
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('${commonField.displayName} copied.'),
      ));
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('${commonField.displayName} is empty.'),
      ));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    subscriptions.cancelSubscriptions();
    _initTextControllers();
    _initShortcutListener(Provider.of<KeyboardShortcutEvents>(context), Provider.of<CommonFields>(context));
  }

  @override
  Widget build(BuildContext context) {
    final commonFields = Provider.of<CommonFields>(context);

    final nonCommonKeys = widget.entry.stringEntries.where((str) => !commonFields.isCommon(str.key));

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: SafeArea(
          top: false,
          left: false,
          right: false,
          child: Column(
            children: <Widget>[
              ...commonFields.fields
                  .map(
                    (f) => EntryField(
                      entry: widget.entry,
                      fieldKey: f.key,
                      commonField: f,
                    ),
                  )
                  .followedBy(
                    nonCommonKeys.map((key) => EntryField(entry: widget.entry, fieldKey: key.key)),
                  )
                  .expand((el) => [el, const SizedBox(height: 8)]),
              LinkButton(
                icon: Icon(Icons.add_circle_outline),
                child: const Text('Add Field'),
                onPressed: () async {
                  final String key = await SimplePromptDialog.showPrompt(
                    context,
                    const SimplePromptDialog(
                      title: 'Adding new Field',
                      labelText: 'Enter a name for the field',
                    ),
                  );
                  if (key != null && key.isNotEmpty) {
                    widget.entry.setString(KdbxKey(key), PlainValue(''));
                    setState(() {});
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EntryField extends StatefulWidget {
  const EntryField({Key key, @required this.entry, @required this.fieldKey, this.commonField}) : super(key: key);

  final KdbxEntry entry;
  final KdbxKey fieldKey;
  final CommonField commonField;

  @override
  _EntryFieldState createState() => _EntryFieldState();
}

enum EntryAction {
  copy,
  rename,
  protect,
  delete,
}

class _EntryFieldState extends State<EntryField> {
  TextEditingController _controller;
  bool _isProtected = false;

  StringValue _value;

  @override
  void initState() {
    super.initState();
    _value = widget.entry.getString(widget.fieldKey);
    if (_value is ProtectedValue) {
      _isProtected = true;
      _controller = TextEditingController();
    } else {
      _controller = TextEditingController(text: _value?.getText() ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(widget.key),
      background: Container(
        alignment: Alignment.centerLeft,
        color: Colors.lightBlueAccent,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.lock),
            const SizedBox(height: 4),
            const Text('Copy Field'),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
//        await ClipboardManager.copyToClipBoard(_value.getText());
        await Clipboard.setData(ClipboardData(text: _value.getText()));
        return false;
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: <Widget>[
            Expanded(
              child: _isProtected
                  ? Row(children: [
                      const SizedBox(width: 12),
                      Text('${widget.commonField?.displayName ?? widget.fieldKey.key}:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: LinkButton(
                          child: const Text('Protected field. Click here to view and modify.'),
                          onPressed: () {
                            setState(() {
                              _controller.text = _value?.getText() ?? '';
                              _isProtected = false;
                            });
                          },
                        ),
                      ),
                    ])
                  : TextFormField(
                      maxLines: null,
                      decoration: InputDecoration(
                        fillColor: const Color(0xfff0f0f0),
                        filled: true,
                        suffixIcon: _isProtected ? Icon(Icons.lock) : null,
                        labelText: widget.commonField?.displayName ?? widget.fieldKey.key,
                      ),
                      keyboardType: widget.commonField?.keyboardType,
                      controller: _controller,
                      obscureText: _isProtected,
                      onSaved: (value) {
                        final newValue =
                            _value is ProtectedValue ? ProtectedValue.fromString(value) : PlainValue(value);
                        widget.entry.setString(widget.fieldKey, newValue);
                      },
                    ),
            ),
            PopupMenuButton<EntryAction>(
              icon: Icon(Icons.more_vert),
              offset: const Offset(0, 32),
              onSelected: (val) async {
                // TODO implement actions
                switch (val) {
                  case EntryAction.copy:
                    await Clipboard.setData(ClipboardData(text: _value.getText()));
                    return;
                  case EntryAction.rename:
                  case EntryAction.protect:
                  case EntryAction.delete:
                    await DialogUtils.showSimpleAlertDialog(context, null, 'TODO, sorry.');
                    return;
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: EntryAction.copy,
                  child: ListTile(
                    leading: Icon(Icons.content_copy),
                    title: Text('Copy'),
                  ),
                ),
                PopupMenuDivider(),
                PopupMenuItem(
                  value: EntryAction.rename,
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Rename'),
                  ),
                ),
                PopupMenuItem(
                  value: EntryAction.protect,
                  child: ListTile(
                    leading: Icon(Icons.enhanced_encryption),
                    title: Text('Protect Value'),
                  ),
                ),
                PopupMenuItem(
                  value: EntryAction.delete,
                  child: ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('Delete'),
                  ),
                ),
              ],
            )
//            IconButton(
//              icon: Icon(Icons.content_copy),
//              tooltip: 'Copy to clipboard',
//              onPressed: () {
//                ClipboardManager.copyToClipBoard(_value.getText());
//              },
//            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
