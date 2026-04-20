# widget brick

Generate a `DashboardWidget` and mount it on the panel's dashboard.

```bash
mason make widget --name TotalPenjualan --type stat --columnSpan 4
mason make widget --name TrenMingguan   --type chart --columnSpan 6
mason make widget --name Peta           --type custom --columnSpan 12
```

Types:
- `stat` — row of stat tiles (wraps `StatWidget`)
- `chart` — simple bar chart (wraps `ChartWidget`)
- `custom` — blank card with a TODO; implement anything

Auto-registers into `adminPanel.widgets`.
