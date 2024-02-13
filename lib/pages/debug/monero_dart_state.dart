import 'package:xmruw/pages/wallet/transaction_list.dart';
import 'package:xmruw/tools/dirs.dart';
import 'package:xmruw/tools/monero/subaddress_label.dart';
import 'package:xmruw/tools/wallet_manager.dart';
import 'package:xmruw/tools/wallet_ptr.dart';
import 'package:xmruw/widgets/simple_expansion_tile.dart';
import 'package:flutter/material.dart';
import 'package:monero/monero.dart';

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
            SET('MONERO_isLibOk', MONERO_isLibOk()),
            SET('MONERO_TransactionHistory_count',
                MONERO_TransactionHistory_count(txHistoryPtr)),
// MONERO_TransactionHistory_setTxNote(MONERO_TransactionHistory txHistory_ptr, {required String txid, required String note}) → void
// MONERO_TransactionHistory_transaction(MONERO_TransactionHistory txHistory_ptr, {required int index}) → MONERO_TransactionInfo
// MONERO_TransactionInfo_amount(MONERO_TransactionInfo pendingTx_ptr) → int
// MONERO_TransactionInfo_blockHeight(MONERO_TransactionInfo pendingTx_ptr) → int
// MONERO_TransactionInfo_confirmations(MONERO_TransactionInfo pendingTx_ptr) → int
// MONERO_TransactionInfo_description(MONERO_TransactionInfo pendingTx_ptr) → String
// MONERO_TransactionInfo_direction(MONERO_TransactionInfo pendingTx_ptr) → TransactionInfo_Direction
// MONERO_TransactionInfo_fee(MONERO_TransactionInfo pendingTx_ptr) → int
// MONERO_TransactionInfo_hash(MONERO_TransactionInfo pendingTx_ptr) → String
// MONERO_TransactionInfo_isCoinbase(MONERO_TransactionInfo pendingTx_ptr) → bool
// MONERO_TransactionInfo_isFailed(MONERO_TransactionInfo pendingTx_ptr) → bool
// MONERO_TransactionInfo_isPending(MONERO_TransactionInfo pendingTx_ptr) → bool
// MONERO_TransactionInfo_label(MONERO_TransactionInfo pendingTx_ptr) → String
// MONERO_TransactionInfo_paymentId(MONERO_TransactionInfo pendingTx_ptr) → String
// MONERO_TransactionInfo_subaddrAccount(MONERO_TransactionInfo pendingTx_ptr) → int
// MONERO_TransactionInfo_timestamp(MONERO_TransactionInfo pendingTx_ptr) → int
// MONERO_TransactionInfo_unlockTime(MONERO_TransactionInfo pendingTx_ptr) → int
            SET(
                'MONERO_Wallet_address(0,0)',
                MONERO_Wallet_address(walletPtr!,
                    accountIndex: 0, addressIndex: 0)),
            SET(
                'MONERO_Wallet_address(0,1)',
                MONERO_Wallet_address(walletPtr!,
                    accountIndex: 0, addressIndex: 1)),
            SET(
                'MONERO_Wallet_address(0,2)',
                MONERO_Wallet_address(walletPtr!,
                    accountIndex: 0, addressIndex: 2)),
// MONERO_Wallet_addressValid(String address) → bool
            SET('MONERO_Wallet_addressValid(\'asd\')',
                MONERO_Wallet_addressValid('asd', 0)),
            SET(
                'MONERO_Wallet_addressValid(MONERO_Wallet_address(0,0))',
                MONERO_Wallet_addressValid(
                    MONERO_Wallet_address(walletPtr!,
                        accountIndex: 0, addressIndex: 0),
                    0)),
            SET(
                'MONERO_Wallet_addressValid(MONERO_Wallet_address(0,1))',
                MONERO_Wallet_addressValid(
                    MONERO_Wallet_address(walletPtr!,
                        accountIndex: 0, addressIndex: 1),
                    0)),
// MONERO_Wallet_approximateBlockChainHeight(MONERO_wallet wallet_ptr) → int
            SET('MONERO_Wallet_approximateBlockChainHeight',
                MONERO_Wallet_approximateBlockChainHeight(walletPtr!)),
// MONERO_Wallet_autoRefreshInterval(MONERO_wallet wallet_ptr) → int
            SET('MONERO_Wallet_autoRefreshInterval',
                MONERO_Wallet_autoRefreshInterval(walletPtr!)),
// MONERO_Wallet_balance(MONERO_wallet wallet_ptr, {required int accountIndex}) → int
            SET('MONERO_Wallet_balance(0)',
                MONERO_Wallet_balance(walletPtr!, accountIndex: 0)),
// MONERO_Wallet_blockChainHeight(MONERO_wallet wallet_ptr) → int
            SET('MONERO_Wallet_blockChainHeight',
                MONERO_Wallet_blockChainHeight(walletPtr!)),
// MONERO_Wallet_createTransaction(MONERO_wallet wallet_ptr, {required String dst_addr, required String payment_id, required int amount, required int mixin_count, required int pendingTransactionPriority, required int subaddr_account}) → MONERO_PendingTransaction
// MONERO_Wallet_daemonBlockChainHeight(MONERO_wallet wallet_ptr) → int
            SET('MONERO_Wallet_daemonBlockChainHeight',
                MONERO_Wallet_daemonBlockChainHeight(walletPtr!)),
            SET('MONERO_Wallet_daemonBlockChainHeight_cached',
                MONERO_Wallet_daemonBlockChainHeight_cached(walletPtr!)),
// MONERO_Wallet_errorString(MONERO_wallet wallet_ptr) → String
            SET('MONERO_Wallet_errorString',
                MONERO_Wallet_errorString(walletPtr!)),
// MONERO_Wallet_estimateBlockChainHeight(MONERO_wallet wallet_ptr) → int
            SET('MONERO_Wallet_estimateBlockChainHeight',
                MONERO_Wallet_estimateBlockChainHeight(walletPtr!)),
// MONERO_Wallet_exportKeyImages(MONERO_wallet wallet_ptr, String filename, {required bool all}) → bool
// MONERO_Wallet_exportOutputs(MONERO_wallet wallet_ptr, String filename, {required bool all}) → bool
// MONERO_Wallet_getBytesReceived(MONERO_wallet wallet_ptr) → int
            SET('MONERO_Wallet_getBytesReceived',
                MONERO_Wallet_getBytesReceived(walletPtr!)),
            const SET('(crash) MONERO_Wallet_isOffline',
                "MONERO_Wallet_isOffline(walletPtr!)"),
// MONERO_Wallet_getBytesSent(MONERO_wallet wallet_ptr) → int
            const SET('(crash) MONERO_Wallet_getBytesSent',
                'MONERO_Wallet_getBytesSent(walletPtr!)'),
// MONERO_Wallet_getSubaddressLabel(MONERO_wallet wallet_ptr, {required int accountIndex, required int addressIndex}) → String
            SET(
                'MONERO_Wallet_getSubaddressLabel(0, 0)',
                MONERO_Wallet_getSubaddressLabel(walletPtr!,
                    accountIndex: 0, addressIndex: 0)),
            SET(
                'MONERO_Wallet_getSubaddressLabel(0, 1)',
                MONERO_Wallet_getSubaddressLabel(walletPtr!,
                    accountIndex: 0, addressIndex: 0)),
            SET('subaddressLabel(0)', subaddressLabel(0)),
            SET('subaddressLabel(1)', subaddressLabel(1)),
// MONERO_Wallet_history(MONERO_wallet wallet_ptr) → MONERO_TransactionHistory
// MONERO_Wallet_importKeyImages(MONERO_wallet wallet_ptr, String filename) → bool
// MONERO_Wallet_importOutputs(MONERO_wallet wallet_ptr, String filename) → bool
// MONERO_Wallet_init(MONERO_wallet wallet_ptr, {required String daemonAddress, int upperTransacationSizeLimit = 0, String daemonUsername = "", String daemonPassword = "", bool useSsl = false, bool lightWallet = false, String proxyAddress = ""}) → bool
// MONERO_Wallet_init3(MONERO_wallet wallet_ptr, {required String argv0, required String defaultLogBaseName, required String logPath, required bool console}) → void
            SET('MONERO_Wallet_getRefreshFromBlockHeight',
                MONERO_Wallet_getRefreshFromBlockHeight(walletPtr!)),
            SET('MONERO_Wallet_connected', MONERO_Wallet_connected(walletPtr!)),
// MONERO_Wallet_numSubaddressAccounts(MONERO_wallet wallet_ptr) → int
            SET('MONERO_Wallet_numSubaddressAccounts',
                MONERO_Wallet_numSubaddressAccounts(walletPtr!)),
// MONERO_Wallet_numSubaddresses(MONERO_wallet wallet_ptr, {required int accountIndex}) → int
            SET('MONERO_Wallet_numSubaddresses(0)',
                MONERO_Wallet_numSubaddresses(walletPtr!, accountIndex: 0)),
// MONERO_Wallet_pauseRefresh(MONERO_wallet wallet_ptr) → void
// MONERO_Wallet_publicSpendKey(MONERO_wallet wallet_ptr) → String1
            SET('MONERO_Wallet_publicSpendKey',
                MONERO_Wallet_publicSpendKey(walletPtr!)),
// MONERO_Wallet_publicViewKey(MONERO_wallet wallet_ptr) → String
            SET('MONERO_Wallet_publicViewKey',
                MONERO_Wallet_publicViewKey(walletPtr!)),
// MONERO_Wallet_refresh(MONERO_wallet wallet_ptr) → bool
// MONERO_Wallet_refreshAsync(MONERO_wallet wallet_ptr) → void
// MONERO_Wallet_rescanBlockchain(MONERO_wallet wallet_ptr) → bool
// MONERO_Wallet_rescanBlockchainAsync(MONERO_wallet wallet_ptr) → void
// MONERO_Wallet_secretSpendKey(MONERO_wallet wallet_ptr) → String
            SET('MONERO_Wallet_secretSpendKey',
                MONERO_Wallet_secretSpendKey(walletPtr!)),
// MONERO_Wallet_secretViewKey(MONERO_wallet wallet_ptr) → String
            SET('MONERO_Wallet_secretViewKey',
                MONERO_Wallet_secretViewKey(walletPtr!)),
// MONERO_Wallet_seed(MONERO_wallet wallet_ptr) → String
            SET('MONERO_Wallet_seed("")',
                MONERO_Wallet_seed(walletPtr!, seedOffset: "")),
            SET('MONERO_Wallet_seed("m")',
                MONERO_Wallet_seed(walletPtr!, seedOffset: "m")),
// MONERO_Wallet_setAutoRefreshInterval(MONERO_wallet wallet_ptr, {required int millis}) → void
// MONERO_Wallet_setSubaddressLabel(MONERO_wallet wallet_ptr, {required int accountIndex, required int addressIndex, required String label}) → void
// MONERO_Wallet_startRefresh(MONERO_wallet wallet_ptr) → void
// MONERO_Wallet_status(MONERO_wallet wallet_ptr) → int
            SET('MONERO_Wallet_status', MONERO_Wallet_status(walletPtr!)),
// MONERO_Wallet_stop(MONERO_wallet wallet_ptr) → void
// MONERO_Wallet_store(MONERO_wallet wallet_ptr, {String path = ""}) → bool
// MONERO_Wallet_submitTransaction(MONERO_wallet wallet_ptr, String filename) → bool
// MONERO_Wallet_synchronized(MONERO_wallet wallet_ptr) → bool
            SET('MONERO_Wallet_synchronized',
                MONERO_Wallet_synchronized(walletPtr!)),
// MONERO_Wallet_unlockedBalance(MONERO_wallet wallet_ptr, {required int accountIndex}) → int
            SET('MONERO_Wallet_unlockedBalance(0)',
                MONERO_Wallet_unlockedBalance(walletPtr!, accountIndex: 0)),
// MONERO_Wallet_watchOnly(MONERO_wallet wallet_ptr) → bool
            SET('MONERO_Wallet_watchOnly', MONERO_Wallet_watchOnly(walletPtr!)),
// MONERO_WalletManager_closeWallet(MONERO_wallet wallet_ptr, bool store) → bool
// MONERO_WalletManager_createWallet({required String path, required String password, String language = "English", int networkType = 0}) → MONERO_wallet
// MONERO_WalletManager_errorString() → String
            SET('MONERO_WalletManager_errorString',
                MONERO_WalletManager_errorString(wmPtr)),
// MONERO_WalletManager_openWallet({required String path, required String password, int networkType = 0}) → MONERO_wallet
// MONERO_WalletManager_recoveryWallet({required String path, required String password, required String mnemonic, int networkType = 0, required int restoreHeight, int kdfRounds = 0, required String seedOffset}) → MONERO_wallet
// MONERO_WalletManager_setDaemonAddress(String address) → void
// MONERO_WalletManager_walletExists(String path) → bool
            SET('MONERO_WalletManager_walletExists(await getMainWalletPath())',
                MONERO_WalletManager_walletExists(wmPtr, mainWalletPath)),
          ],
        ),
      ),
    );
  }
}
