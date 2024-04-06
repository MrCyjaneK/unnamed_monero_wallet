import 'package:flutter/material.dart';
import 'package:monero/monero.dart' as monero;
import 'package:xmruw/pages/wallet/transaction_list.dart';
import 'package:xmruw/tools/dirs.dart';
import 'package:xmruw/tools/monero/account_index.dart';
import 'package:xmruw/tools/monero/subaddress_label.dart';
import 'package:xmruw/tools/wallet_manager.dart';
import 'package:xmruw/tools/wallet_ptr.dart';
import 'package:xmruw/widgets/simple_expansion_tile.dart';

const String about = """
This simply represents everything that is happening at the monero side of things
this page may be slow as it does a blocking call to all the functions below when
it is opened.""";

class MoneroDartState extends StatefulWidget {
  const MoneroDartState({super.key});

  @override
  State<MoneroDartState> createState() => _MoneroDartStateState();

  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const MoneroDartState();
      },
    ));
  }
}

class _MoneroDartStateState extends State<MoneroDartState> {
  String mainWalletPath = '';
  @override
  void initState() {
    getMainWalletPath().then((value) {
      setState(() {
        mainWalletPath = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("monero.dart state"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SET('about', about),
            SET('global walletPtr', walletPtr),
            SET('txHistPtr', txHistoryPtr),
            SET('MONERO_isLibOk', monero.isLibOk()),
            SET('MONERO_TransactionHistory_count',
                monero.TransactionHistory_count(txHistoryPtr)),
//monero.TransactionHistory_setTxNote(MONERO_TransactionHistory txHistory_ptr, {required String txid, required String note}) → void
//monero.TransactionHistory_transaction(MONERO_TransactionHistory txHistory_ptr, {required int index}) →monero.TransactionInfo
//monero.TransactionInfo_amount(MONERO_TransactionInfo pendingTx_ptr) → int
//monero.TransactionInfo_blockHeight(MONERO_TransactionInfo pendingTx_ptr) → int
//monero.TransactionInfo_confirmations(MONERO_TransactionInfo pendingTx_ptr) → int
//monero.TransactionInfo_description(MONERO_TransactionInfo pendingTx_ptr) → String
//monero.TransactionInfo_direction(MONERO_TransactionInfo pendingTx_ptr) → TransactionInfo_Direction
//monero.TransactionInfo_fee(MONERO_TransactionInfo pendingTx_ptr) → int
//monero.TransactionInfo_hash(MONERO_TransactionInfo pendingTx_ptr) → String
//monero.TransactionInfo_isCoinbase(MONERO_TransactionInfo pendingTx_ptr) → bool
//monero.TransactionInfo_isFailed(MONERO_TransactionInfo pendingTx_ptr) → bool
//monero.TransactionInfo_isPending(MONERO_TransactionInfo pendingTx_ptr) → bool
//monero.TransactionInfo_label(MONERO_TransactionInfo pendingTx_ptr) → String
//monero.TransactionInfo_paymentId(MONERO_TransactionInfo pendingTx_ptr) → String
//monero.TransactionInfo_subaddrAccount(MONERO_TransactionInfo pendingTx_ptr) → int
//monero.TransactionInfo_timestamp(MONERO_TransactionInfo pendingTx_ptr) → int
//monero.TransactionInfo_unlockTime(MONERO_TransactionInfo pendingTx_ptr) → int
            SET(
                'MONERO_Wallet_address($globalAccountIndex,0)',
                monero.Wallet_address(walletPtr!,
                    accountIndex: globalAccountIndex, addressIndex: 0)),
            SET(
                'MONERO_Wallet_address($globalAccountIndex,1)',
                monero.Wallet_address(walletPtr!,
                    accountIndex: globalAccountIndex, addressIndex: 1)),
            SET(
                'MONERO_Wallet_address($globalAccountIndex,2)',
                monero.Wallet_address(walletPtr!,
                    accountIndex: globalAccountIndex, addressIndex: 2)),
//monero.Wallet_addressValid(String address) → bool
            SET('MONERO_Wallet_addressValid(\'asd\')',
                monero.Wallet_addressValid('asd', 0)),
            SET(
                'MONERO_Wallet_addressValid(MONERO_Wallet_address($globalAccountIndex,0))',
                monero.Wallet_addressValid(
                    monero.Wallet_address(walletPtr!,
                        accountIndex: globalAccountIndex, addressIndex: 0),
                    0)),
            SET(
                'MONERO_Wallet_addressValid(MONERO_Wallet_address($globalAccountIndex,1))',
                monero.Wallet_addressValid(
                    monero.Wallet_address(walletPtr!,
                        accountIndex: globalAccountIndex, addressIndex: 1),
                    0)),
//monero.Wallet_approximateBlockChainHeight(MONERO_wallet wallet_ptr) → int
            SET('MONERO_Wallet_approximateBlockChainHeight',
                monero.Wallet_approximateBlockChainHeight(walletPtr!)),
//monero.Wallet_autoRefreshInterval(MONERO_wallet wallet_ptr) → int
            SET('MONERO_Wallet_autoRefreshInterval',
                monero.Wallet_autoRefreshInterval(walletPtr!)),
//monero.Wallet_balance(MONERO_wallet wallet_ptr, {required int accountIndex}) → int
            SET(
                'MONERO_Wallet_balance($globalAccountIndex)',
                monero.Wallet_balance(walletPtr!,
                    accountIndex: globalAccountIndex)),
//monero.Wallet_blockChainHeight(MONERO_wallet wallet_ptr) → int
            SET('MONERO_Wallet_blockChainHeight',
                monero.Wallet_blockChainHeight(walletPtr!)),
//monero.Wallet_createTransaction(MONERO_wallet wallet_ptr, {required String dst_addr, required String payment_id, required int amount, required int mixin_count, required int pendingTransactionPriority, required int subaddr_account}) →monero.PendingTransaction
//monero.Wallet_daemonBlockChainHeight(MONERO_wallet wallet_ptr) → int
            SET('MONERO_Wallet_daemonBlockChainHeight',
                monero.Wallet_daemonBlockChainHeight(walletPtr!)),
            SET('MONERO_Wallet_daemonBlockChainHeight_cached',
                monero.Wallet_daemonBlockChainHeight_cached(walletPtr!)),
//monero.Wallet_errorString(MONERO_wallet wallet_ptr) → String
            SET('MONERO_Wallet_errorString',
                monero.Wallet_errorString(walletPtr!)),
//monero.Wallet_estimateBlockChainHeight(MONERO_wallet wallet_ptr) → int
            SET('MONERO_Wallet_estimateBlockChainHeight',
                monero.Wallet_estimateBlockChainHeight(walletPtr!)),
//monero.Wallet_exportKeyImages(MONERO_wallet wallet_ptr, String filename, {required bool all}) → bool
//monero.Wallet_exportOutputs(MONERO_wallet wallet_ptr, String filename, {required bool all}) → bool
//monero.Wallet_getBytesReceived(MONERO_wallet wallet_ptr) → int
            SET('MONERO_Wallet_getBytesReceived',
                monero.Wallet_getBytesReceived(walletPtr!)),
            const SET('(crash)monero.Wallet_isOffline',
                "MONERO_Wallet_isOffline(walletPtr!)"),
//monero.Wallet_getBytesSent(MONERO_wallet wallet_ptr) → int
            const SET('(crash)monero.Wallet_getBytesSent',
                'MONERO_Wallet_getBytesSent(walletPtr!)'),
//monero.Wallet_getSubaddressLabel(MONERO_wallet wallet_ptr, {required int accountIndex, required int addressIndex}) → String
            SET(
                'MONERO_Wallet_getSubaddressLabel($globalAccountIndex, 0)',
                monero.Wallet_getSubaddressLabel(walletPtr!,
                    accountIndex: globalAccountIndex, addressIndex: 0)),
            SET(
                'MONERO_Wallet_getSubaddressLabel($globalAccountIndex, 1)',
                monero.Wallet_getSubaddressLabel(walletPtr!,
                    accountIndex: globalAccountIndex, addressIndex: 0)),
            SET('subaddressLabel(0)', subaddressLabel(0)),
            SET('subaddressLabel(1)', subaddressLabel(1)),
//monero.Wallet_history(MONERO_wallet wallet_ptr) →monero.TransactionHistory
//monero.Wallet_importKeyImages(MONERO_wallet wallet_ptr, String filename) → bool
//monero.Wallet_importOutputs(MONERO_wallet wallet_ptr, String filename) → bool
//monero.Wallet_init(MONERO_wallet wallet_ptr, {required String daemonAddress, int upperTransacationSizeLimit = 0, String daemonUsername = "", String daemonPassword = "", bool useSsl = false, bool lightWallet = false, String proxyAddress = ""}) → bool
//monero.Wallet_init3(MONERO_wallet wallet_ptr, {required String argv0, required String defaultLogBaseName, required String logPath, required bool console}) → void
            SET('MONERO_Wallet_getRefreshFromBlockHeight',
                monero.Wallet_getRefreshFromBlockHeight(walletPtr!)),
            SET('MONERO_Wallet_connected', monero.Wallet_connected(walletPtr!)),
//monero.Wallet_numSubaddressAccounts(MONERO_wallet wallet_ptr) → int
            SET('MONERO_Wallet_numSubaddressAccounts',
                monero.Wallet_numSubaddressAccounts(walletPtr!)),
//monero.Wallet_numSubaddresses(MONERO_wallet wallet_ptr, {required int accountIndex}) → int
            SET(
                'MONERO_Wallet_numSubaddresses($globalAccountIndex)',
                monero.Wallet_numSubaddresses(walletPtr!,
                    accountIndex: globalAccountIndex)),
//monero.Wallet_pauseRefresh(MONERO_wallet wallet_ptr) → void
//monero.Wallet_publicSpendKey(MONERO_wallet wallet_ptr) → String1
            SET('MONERO_Wallet_publicSpendKey',
                monero.Wallet_publicSpendKey(walletPtr!)),
//monero.Wallet_publicViewKey(MONERO_wallet wallet_ptr) → String
            SET('MONERO_Wallet_publicViewKey',
                monero.Wallet_publicViewKey(walletPtr!)),
//monero.Wallet_refresh(MONERO_wallet wallet_ptr) → bool
//monero.Wallet_refreshAsync(MONERO_wallet wallet_ptr) → void
//monero.Wallet_rescanBlockchain(MONERO_wallet wallet_ptr) → bool
//monero.Wallet_rescanBlockchainAsync(MONERO_wallet wallet_ptr) → void
//monero.Wallet_secretSpendKey(MONERO_wallet wallet_ptr) → String
            SET('MONERO_Wallet_secretSpendKey',
                monero.Wallet_secretSpendKey(walletPtr!)),
//monero.Wallet_secretViewKey(MONERO_wallet wallet_ptr) → String
            SET('MONERO_Wallet_secretViewKey',
                monero.Wallet_secretViewKey(walletPtr!)),
//monero.Wallet_seed(MONERO_wallet wallet_ptr) → String
            SET('MONERO_Wallet_seed("")',
                monero.Wallet_seed(walletPtr!, seedOffset: "")),
            SET('MONERO_Wallet_seed("m")',
                monero.Wallet_seed(walletPtr!, seedOffset: "m")),
//monero.Wallet_setAutoRefreshInterval(MONERO_wallet wallet_ptr, {required int millis}) → void
//monero.Wallet_setSubaddressLabel(MONERO_wallet wallet_ptr, {required int accountIndex, required int addressIndex, required String label}) → void
//monero.Wallet_startRefresh(MONERO_wallet wallet_ptr) → void
//monero.Wallet_status(MONERO_wallet wallet_ptr) → int
            SET('MONERO_Wallet_status', monero.Wallet_status(walletPtr!)),
//monero.Wallet_stop(MONERO_wallet wallet_ptr) → void
//monero.Wallet_store(MONERO_wallet wallet_ptr, {String path = ""}) → bool
//monero.Wallet_submitTransaction(MONERO_wallet wallet_ptr, String filename) → bool
//monero.Wallet_synchronized(MONERO_wallet wallet_ptr) → bool
            SET('MONERO_Wallet_synchronized',
                monero.Wallet_synchronized(walletPtr!)),
//monero.Wallet_unlockedBalance(MONERO_wallet wallet_ptr, {required int accountIndex}) → int
            SET(
                'MONERO_Wallet_unlockedBalance($globalAccountIndex)',
                monero.Wallet_unlockedBalance(walletPtr!,
                    accountIndex: globalAccountIndex)),
//monero.Wallet_watchOnly(MONERO_wallet wallet_ptr) → bool
            SET('MONERO_Wallet_watchOnly', monero.Wallet_watchOnly(walletPtr!)),
//monero.WalletManager_closeWallet(MONERO_wallet wallet_ptr, bool store) → bool
//monero.WalletManager_createWallet({required String path, required String password, String language = "English", int networkType = 0}) →monero.wallet
//monero.WalletManager_errorString() → String
            SET('MONERO_WalletManager_errorString',
                monero.WalletManager_errorString(wmPtr)),
//monero.WalletManager_openWallet({required String path, required String password, int networkType = 0}) →monero.wallet
//monero.WalletManager_recoveryWallet({required String path, required String password, required String mnemonic, int networkType = 0, required int restoreHeight, int kdfRounds = 0, required String seedOffset}) →monero.wallet
//monero.WalletManager_setDaemonAddress(String address) → void
//monero.WalletManager_walletExists(String path) → bool
            SET('MONERO_WalletManager_walletExists(await getMainWalletPath())',
                monero.WalletManager_walletExists(wmPtr, mainWalletPath)),
          ],
        ),
      ),
    );
  }
}
