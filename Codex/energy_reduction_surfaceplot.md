
def build_grid(steps: int = 96):
    """Create X, Y grids and corresponding Z values."""
    r3 = 14.811
    r4 = 14.811
    r5 = 5.183
    coeff = r3 + r4 + r5

    # 96 values each: X descends 1 -> just above 0 in -1/96 increments.
    x_vals = np.linspace(1.0, 0.0, steps, endpoint=False)
    # 96 values: Y ascends 1/96 -> 1 in 1/96 increments.
    y_vals = np.linspace(1.0 / steps, 1.0, steps)

    X, Y = np.meshgrid(x_vals, y_vals)
    Z = coeff * X * Y * 24
    return X, Y, Z


def plot_surface(X, Y, Z, outfile: str = "total_energy_reduction_surface.png"):
    """Plot and save the surface."""
    fig = plt.figure(figsize=(9, 6))
    ax = fig.add_subplot(111, projection="3d")

    surf = ax.plot_surface(X, Y, Z, cmap=cm.viridis, linewidth=0, antialiased=True, alpha=0.9)

    ax.set_xlabel("Energy Reduction")
    ax.set_ylabel("Duration per 24-hr")
    ax.set_zlabel("Total Energy Reduction")
    ax.set_title("Total Energy Reduction Surface")

    ax.set_xlim(1, 0)  # Keep the descending X axis intuitive.
    ax.view_init(elev=25, azim=-60)
    fig.colorbar(surf, shrink=0.6, aspect=12, label="Total Energy Reduction")
    plt.tight_layout()
    plt.savefig(outfile, dpi=200)
    return outfile
